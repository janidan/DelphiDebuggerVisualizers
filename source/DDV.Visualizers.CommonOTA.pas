unit DDV.Visualizers.CommonOTA;

// Delphi Code Visualizers
// Copyright (c) 2020 Tobias Rörig
// https://github.com/janidan/DelphiDebuggerVisualizers

{* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. *}

interface

uses
  ToolsAPI;

type
  TCommonNotifier = class( TInterfacedObject, IOTANotifier )
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

  TCommonThreadNotifier = class( TCommonNotifier, IOTAThreadNotifier, IOTAThreadNotifier160 )
  protected
    {$REGION 'IOTAThreadNotifier interface implementation'}
    { This is called when the process state changes for this thread }
    procedure ThreadNotify( Reason: TOTANotifyReason ); virtual;
    { This is called when an evaluate that returned erDeferred completes.
      ReturnCode <> 0 if error }
    procedure EvaluteComplete( const ExprStr, ResultStr: string; CanModify: Boolean; ResultAddress, ResultSize: LongWord; ReturnCode: Integer );
    { This is called when a modify that returned erDeferred completes.
      ReturnCode <> 0 if error }
    procedure ModifyComplete( const ExprStr, ResultStr: string; ReturnCode: Integer ); virtual;
    {$ENDREGION 'IOTAThreadNotifier interface implementation'}
    {$REGION 'IOTAThreadNotifier160 interface implementation'}
    { This is called when an evaluate that returned erDeferred completes.
      ReturnCode <> 0 if error }
    procedure EvaluateComplete( const ExprStr, ResultStr: string; CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord;
      ReturnCode: Integer ); virtual;
    {$ENDREGION 'IOTAThreadNotifier160 interface implementation'}
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

procedure TCommonThreadNotifier.EvaluateComplete( const ExprStr, ResultStr: string; CanModify: Boolean; ResultAddress: TOTAAddress; ResultSize: LongWord;
  ReturnCode: Integer );
begin
  // Empty implementation on purpose - to be overridden by decendents
end;

procedure TCommonThreadNotifier.EvaluteComplete( const ExprStr, ResultStr: string; CanModify: Boolean; ResultAddress, ResultSize: LongWord;
  ReturnCode: Integer );
begin
  EvaluateComplete( ExprStr, ResultStr, CanModify, TOTAAddress( ResultAddress ), LongWord( ResultSize ), ReturnCode );
end;

procedure TCommonThreadNotifier.ModifyComplete( const ExprStr, ResultStr: string; ReturnCode: Integer );
begin
  // Empty implementation on purpose - to be overridden by decendents
end;

procedure TCommonThreadNotifier.ThreadNotify( Reason: TOTANotifyReason );
begin
  // Empty implementation on purpose - to be overridden by decendents
end;

end.
