unit DDV.Visualizers.Evaluator;

// Delphi Code Visualizers
// Copyright (c) 2020 Tobias Rörig
// https://github.com/janidan/DelphiDebuggerVisualizers

{* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. *}

interface

uses
  ToolsAPI,
  DDV.Visualizers.CommonOTA;

type
  IDDVDebuggerEvaluator = interface
    ['{22725F0B-CC8D-44FF-B38C-0C143A32BA07}']
    /// <summary>
    ///  Executes the given Call in the IDE evaluator.
    ///  If the evaluation is not successfull, the return value will hold the error message of the
    ///  evaluation.
    ///  NOTE: this call only returns when the evaluation is done.
    /// </summary>
    function ExecuteEvaluation( const aEvaluationCall: string ): string; overload;
    /// <summary>
    ///  Executes the given Call in the IDE evaluator.
    ///  If the evaluation is not successfull, the return value will hold the default value supplied.
    ///  NOTE: this call only returns when the evaluation is done.
    /// </summary>
    function ExecuteEvaluation( const aEvaluationCall: string; const aDefaultValue: string ): string; overload;
    /// <summary>
    ///  Executes the given Call in the IDE evaluator.
    ///  If the evaluation is not successfull, the out value will hold the error message of the
    ///  evaluation and the return value will be false.
    ///  NOTE: this call only returns when the evaluation is done.
    /// </summary>
    function TryExecuteEvaluation( const aEvaluationCall: string; out aEvaluationResult: string ): Boolean;
  end;

  TDebuggerEvaluator = class( TCommonThreadNotifier, IDDVDebuggerEvaluator )
  private
    // The DeferredEvaluation variables are used for storing the temporary results during the ExecuteEvaluation call.
    FDeferredEvaluationNotifierIndex: Integer;
    FDeferredEvaluationCompleted: Boolean;
    FDeferredEvaluationResult: string;
    FDeferredEvaluationResultError: Boolean;
  protected
    {$REGION 'IDDVDebuggerEvaluator interface implementation'}
    function ExecuteEvaluation( const aEvaluationCall: string ): string; overload;
    function ExecuteEvaluation( const aEvaluationCall: string; const aDefaultValue: string ): string; overload;
    function TryExecuteEvaluation( const aEvaluationCall: string; out aEvaluationResult: string ): Boolean;
    {$ENDREGION 'IDDVDebuggerEvaluator interface implementation'}
    procedure EvaluateComplete( const ExprStr, ResultStr: string; CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord;
      ReturnCode: Integer ); override;
  end;

implementation

uses
  System.SysUtils;

{ TDebuggerEvaluator }

procedure TDebuggerEvaluator.EvaluateComplete( const ExprStr, ResultStr: string; CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord;
  ReturnCode: Integer );
begin
  FDeferredEvaluationResultError := ( ReturnCode <> 0 );
  FDeferredEvaluationResult := ResultStr;
  FDeferredEvaluationCompleted := True;
end;

function TDebuggerEvaluator.ExecuteEvaluation( const aEvaluationCall: string ): string;
begin
  TryExecuteEvaluation( aEvaluationCall, Result );
end;

function TDebuggerEvaluator.ExecuteEvaluation( const aEvaluationCall: string; const aDefaultValue: string ): string;
begin
  if not TryExecuteEvaluation( aEvaluationCall, Result ) then
    Result := aDefaultValue;
end;

function TDebuggerEvaluator.TryExecuteEvaluation( const aEvaluationCall: string; out aEvaluationResult: string ): Boolean;
var
  CurProcess: IOTAProcess;
  CurThread: IOTAThread;
  ResultStr: array [0 .. 4095] of Char;
  CanModify: Boolean;
  Done: Boolean;
  ResultAddr: TOTAAddress;
  ResultSize, ResultVal: LongWord;
  EvalRes: TOTAEvaluateResult;
  DebugSvcs: IOTADebuggerServices;
begin
  Result := False;
  aEvaluationResult := 'IOTADebuggerServices not supported';
  if not Supports( BorlandIDEServices, IOTADebuggerServices, DebugSvcs ) then
    Exit;

  CurProcess := DebugSvcs.CurrentProcess;
  if Assigned( CurProcess ) then
  begin
    CurThread := CurProcess.CurrentThread;
    if Assigned( CurThread ) then
    begin
      repeat
        Done := True;
        EvalRes := CurThread.Evaluate( aEvaluationCall, @ResultStr, Length( ResultStr ), CanModify, eseAll, '', ResultAddr, ResultSize, ResultVal, '', 0 );
        case EvalRes of
          erOK: { indicates evaluate operation was successful }
            begin
              aEvaluationResult := ResultStr;
              Result := True;
            end;
          erError: { indicates evaluate operation was unsuccessful }
            aEvaluationResult := Format( 'Error: %s', [ResultStr] );
          erDeferred: { indicates evaluate operation is deferred }
            begin
              FDeferredEvaluationCompleted := False;
              FDeferredEvaluationResult := '';
              FDeferredEvaluationResultError := False;
              FDeferredEvaluationNotifierIndex := CurThread.AddNotifier( Self );

              while not FDeferredEvaluationCompleted do
                DebugSvcs.ProcessDebugEvents;

              CurThread.RemoveNotifier( FDeferredEvaluationNotifierIndex );
              FDeferredEvaluationNotifierIndex := -1;
              if FDeferredEvaluationResultError then
                aEvaluationResult := Format( 'Error: %s', [FDeferredEvaluationResult] )
              else // Calculation successfull
              begin
                if ( FDeferredEvaluationResult <> '' ) then
                  aEvaluationResult := FDeferredEvaluationResult
                else
                  aEvaluationResult := ResultStr;
                Result := True;
              end;
            end;
          erBusy: { indicates evaluate operation was not attempted due to the evaluator already processing another evaluate operation }
            begin
              DebugSvcs.ProcessDebugEvents;
              Done := False;
            end;
        end;
      until Done;
    end
    else
      aEvaluationResult := 'No Current Thread found';
  end
  else
    aEvaluationResult := 'No Current Process found';
end;

end.
