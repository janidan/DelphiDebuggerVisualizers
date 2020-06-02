unit DDV.Visualizers.Common;

{ Delphi Code Visualizers
  Copyright (c) 2020 Tobias Rörig
  https://github.com/janidan/DelphiDebuggerVisualizers }

{* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. *}

interface

uses
  ToolsAPI;

type
  TCommonNotifier = class(TInterfacedObject, IOTANotifier)
  protected
    {$REGION 'IOTANotifier interface implementation'}
    { This procedure is called immediately after the item is successfully saved.
      This is not called for IOTAWizards }
    procedure AfterSave; virtual;
    { This function is called immediately before the item is saved. This is not
      called for IOTAWizard }
    procedure BeforeSave; virtual;
    { The associated item is being destroyed so all references should be dropped.
      Exceptions are ignored. }
    procedure Destroyed; virtual;
    { This associated item was modified in some way. This is not called for
      IOTAWizards }
    procedure Modified; virtual;
    {$ENDREGION 'IOTANotifier interface implementation'}
  end;

  TCommonThreadNotifier = class(TCommonNotifier,
    IOTAThreadNotifier, IOTAThreadNotifier160)
  protected
    {$REGION 'IOTAThreadNotifier interface implementation'}
    { This is called when the process state changes for this thread }
    procedure ThreadNotify(Reason: TOTANotifyReason); virtual;
    { This is called when an evaluate that returned erDeferred completes.
      ReturnCode <> 0 if error }
    procedure EvaluteComplete(const ExprStr, ResultStr: string;
      CanModify: Boolean; ResultAddress, ResultSize: LongWord;
      ReturnCode: Integer);
    { This is called when a modify that returned erDeferred completes.
      ReturnCode <> 0 if error }
    procedure ModifyComplete(const ExprStr, ResultStr: string;
      ReturnCode: Integer); virtual;
   {$ENDREGION 'IOTAThreadNotifier interface implementation'}
   {$REGION 'IOTAThreadNotifier160 interface implementation'}
    { This is called when an evaluate that returned erDeferred completes.
      ReturnCode <> 0 if error }
    procedure EvaluateComplete(const ExprStr, ResultStr: string;
      CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord;
      ReturnCode: Integer); virtual;
   {$ENDREGION 'IOTAThreadNotifier160 interface implementation'}
  end;

  TCommonDebuggerVisualizerType = record
    TypeName: string;
    AllDescendants: Boolean;
    IsGeneric: Boolean;
  end;

  TCommonDebuggerVisualizer = class(TCommonThreadNotifier,
    IOTADebuggerVisualizer, IOTADebuggerVisualizer250,
    IOTADebuggerVisualizerValueReplacer)
  protected
    function ConvertStaticToDynamicArray<T>(const aStatic: array of T) : TArray<T>;
    function GetSupportedTypesList: TArray<TCommonDebuggerVisualizerType>; virtual; abstract;
  protected // Interface implementations
    {$REGION 'IOTADebuggerVisualizer interface implementation'}
    { This is the base for debugger visualizers.  This interface allows you to
      specify a name, a unique identifier, and a description for your visualizer.
      It also allows you to specify which types the visualizer will handle }

    { Return the number of types supported by this visualizer }
    function GetSupportedTypeCount: Integer; virtual;
    { Return the Index'd Type.  TypeName is the type.  AllDescendants indicates
      whether or not types descending from this type should use this visualizer
      as well. }
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean); overload; virtual;
    { Return a unique identifier for this visualizer.  This identifier is used
      as the keyname when storing data for this visualizer in the registry.  It
      should not be translated }
    function GetVisualizerIdentifier: string; virtual;
    { Return the name of the visualizer to be shown in the Tools  Options dialog }
    function GetVisualizerName: string; virtual;
    { Return a description of the visualizer to be shown in the Tools | Options dialog }
    function GetVisualizerDescription: string; virtual;
    {$ENDREGION 'IOTADebuggerVisualizer interface implementation'}
    {$REGION 'IOTADebuggerVisualizer250 interface implementation'}
    { Return the Index'd Type.  TypeName is the type.  AllDescendants indicates
      whether or not types descending from this type should use this visualizer
      as well. IsGeneric indicates whether this type is a generic type. }
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean; var IsGeneric: Boolean); overload; virtual;
    {$ENDREGION 'IOTADebuggerVisualizer250 interface implementation'}
    {$REGION 'IOTADebuggerVisualizerValueReplacer interface implementation'}
    { This is the simplest form of a debug visualizer.  With it, you can replace
      the value returned by the evaluator with a more meaningful value.  The
      replacement value will appear in the normal debugger UI (i.e. Evaluator
      Tooltips, Watch View, Locals View, Evaluate/Modify dialog,
      Debug Inspector View).
      There can be only one active IOTADebuggerVisualizerValueReplacer per type }
    function GetReplacementValue(const Expression, TypeName, EvalResult: string)
      : string; virtual;
    {$ENDREGION 'IOTADebuggerVisualizerValueReplacer interface implementation'}
  end;

  TCommonDebuggerEvaluationVisualizer = class(TCommonDebuggerVisualizer)
  private
    // The DeferredEvaluation variables are used for storing the temporary results during the ExecuteEvaluation call.
    FDeferredEvaluationNotifierIndex: Integer;
    FDeferredEvaluationCompleted: Boolean;
    FDeferredEvaluationResult: string;
    FDeferredEvaluationResultError: Boolean;
  protected
    /// <summary>Executes the given Call in the IDE evaluator. NOTE: this call only returns when the evaluation is done.</summary>
    function ExecuteEvaluation(const aEvaluationCall, aOriginalEvalResult : string): string;
    function GetEvaluationCall(const Expression, TypeName, EvalResult: string): string; virtual; abstract;
    function GetReplacementValue(const Expression, TypeName, EvalResult: string): string; override;
    procedure EvaluateComplete(const ExprStr, ResultStr: string;
      CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord;
      ReturnCode: Integer); override;
  end;

implementation

uses
  System.SysUtils;

{ TCommonNotifier }

procedure TCommonNotifier.AfterSave;
begin
  // Empty implementation on purpose - to be overridden by decendents
end;

procedure TCommonNotifier.BeforeSave;
begin
  // Empty implementation on purpose - to be overridden by decendents
end;

procedure TCommonNotifier.Destroyed;
begin
  // Empty implementation on purpose - to be overridden by decendents
end;

procedure TCommonNotifier.Modified;
begin
  // Empty implementation on purpose - to be overridden by decendents
end;

{ TCommonThreadNotifier }

procedure TCommonThreadNotifier.EvaluateComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress: TOTAAddress;
  ResultSize: LongWord; ReturnCode: Integer);
begin
  // Empty implementation on purpose - to be overridden by decendents
end;

procedure TCommonThreadNotifier.EvaluteComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress, ResultSize: LongWord;
  ReturnCode: Integer);
begin
  EvaluateComplete(ExprStr, ResultStr, CanModify, TOTAAddress(ResultAddress),
    LongWord(ResultSize), ReturnCode);
end;

procedure TCommonThreadNotifier.ModifyComplete(const ExprStr, ResultStr: string;
  ReturnCode: Integer);
begin
  // Empty implementation on purpose - to be overridden by decendents
end;

procedure TCommonThreadNotifier.ThreadNotify(Reason: TOTANotifyReason);
begin
  // Empty implementation on purpose - to be overridden by decendents
end;

{ TCommonDebuggerVisualizer }

function TCommonDebuggerVisualizer.ConvertStaticToDynamicArray<T>
  (const aStatic: array of T): TArray<T>;
var
  i: Integer;
begin
  SetLength(Result, Length(aStatic));
  for i := 0 to high(aStatic) do
    Result[i] := aStatic[i];
end;

function TCommonDebuggerVisualizer.GetReplacementValue(const Expression,
  TypeName, EvalResult: string): string;
begin
  Result := Format('%s : %s = %s', [Expression, TypeName, EvalResult]);
end;

procedure TCommonDebuggerVisualizer.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants, IsGeneric: Boolean);
var
  vTypeInfo: TCommonDebuggerVisualizerType;
begin
  vTypeInfo := GetSupportedTypesList[Index];
  TypeName := vTypeInfo.TypeName;
  AllDescendants := vTypeInfo.AllDescendants;
  IsGeneric := vTypeInfo.IsGeneric;
end;

procedure TCommonDebuggerVisualizer.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants: Boolean);
var
  vTypeInfo: TCommonDebuggerVisualizerType;
begin
  vTypeInfo := GetSupportedTypesList[Index];
  TypeName := vTypeInfo.TypeName;
  AllDescendants := vTypeInfo.AllDescendants;
end;

function TCommonDebuggerVisualizer.GetSupportedTypeCount: Integer;
begin
  Result := Length(GetSupportedTypesList);
end;

function TCommonDebuggerVisualizer.GetVisualizerDescription: string;
begin
  Result := GetVisualizerName;
end;

function TCommonDebuggerVisualizer.GetVisualizerIdentifier: string;
begin
  Result := ClassName;
end;

function TCommonDebuggerVisualizer.GetVisualizerName: string;
begin
  Result := GetVisualizerIdentifier;
end;

{ TCommonDebuggerEvaluationVisualizer }

procedure TCommonDebuggerEvaluationVisualizer.EvaluateComplete(const ExprStr,
  ResultStr: string; CanModify: Boolean; ResultAddress: TOTAAddress;
  ResultSize: LongWord; ReturnCode: Integer);
begin
  FDeferredEvaluationResultError := (ReturnCode <> 0);
  FDeferredEvaluationResult := ResultStr;
  FDeferredEvaluationCompleted := True;
end;

function TCommonDebuggerEvaluationVisualizer.ExecuteEvaluation(
  const aEvaluationCall, aOriginalEvalResult: string): string;
var
  CurProcess: IOTAProcess;
  CurThread: IOTAThread;
  ResultStr: array [0 .. 4095] of Char;
  CanModify: Boolean;
  Done: Boolean;
  ResultAddr, ResultSize, ResultVal: LongWord;
  EvalRes: TOTAEvaluateResult;
  DebugSvcs: IOTADebuggerServices;
begin
  Result := '';
  if not Supports(BorlandIDEServices, IOTADebuggerServices, DebugSvcs) then
    Exit;

  CurProcess := DebugSvcs.CurrentProcess;
  if Assigned(CurProcess) then
  begin
    CurThread := CurProcess.CurrentThread;
    if Assigned(CurThread) then
      repeat
        Done := True;
        EvalRes := CurThread.Evaluate(aEvaluationCall, @ResultStr,
          Length(ResultStr), CanModify, eseAll, '', ResultAddr, ResultSize,
          ResultVal, '', 0);
        case EvalRes of
          { erOK       - indicates evaluate operation was successful
            erError    - indicates evaluate operation was unsuccessful
            erDeferred - indicates evaluate operation is deferred
            erBusy     - indicates evaluate operation was not attempted due to the
            evaluator already processing another evaluate operation }
          erOK:
            Result := ResultStr;
          erError:
            Result := Format('%s Error: %s', [aOriginalEvalResult, ResultStr]);
          erDeferred:
            begin
              FDeferredEvaluationCompleted := False;
              FDeferredEvaluationResult := '';
              FDeferredEvaluationResultError := False;
              FDeferredEvaluationNotifierIndex := CurThread.AddNotifier(Self);

              while not FDeferredEvaluationCompleted do
                DebugSvcs.ProcessDebugEvents;

              CurThread.RemoveNotifier(FDeferredEvaluationNotifierIndex);
              FDeferredEvaluationNotifierIndex := -1;
              if FDeferredEvaluationResultError then
                Result := Format('%s Error: %s',
                  [aOriginalEvalResult, FDeferredEvaluationResult])
              else // Calculation successfull
              begin
                if (FDeferredEvaluationResult <> '') then
                  Result := FDeferredEvaluationResult
                else
                  Result := ResultStr;
              end;
            end;
          erBusy:
            begin
              DebugSvcs.ProcessDebugEvents;
              Done := False;
            end;
        end;
      until Done;
  end;
end;

function TCommonDebuggerEvaluationVisualizer.GetReplacementValue(const Expression, TypeName, EvalResult: string): string;
begin
  Result := ExecuteEvaluation(GetEvaluationCall(Expression, TypeName, EvalResult), EvalResult);
end;

end.
