unit DDV.Visualizer.Guid;

{ Delphi Code Visualizers
  Copyright (c) 2020 Tobias Rörig
  https://github.com/janidan/DelphiDebuggerVisualizers }

{* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. *}

interface

procedure Register;

implementation

uses
  System.SysUtils,
  ToolsAPI,
  DDV.Visualizers.Common;

const
  GuidVisualizerTypes: array [0 .. 1] of TCommonDebuggerVisualizerType = (
    ( TypeName: 'TGUID' ), ( TypeName: 'System::TGUID' )  );

resourcestring
  GuidVisualizerName = 'TGUID visualizer';
  GuidVisualizerDescription = 'Visualizes a GUID to a human readable format';

type
  TGuidVisualizer = class( TCommonDebuggerEvaluationVisualizer )
  protected
    function GetSupportedTypesList: TArray<TCommonDebuggerVisualizerType>; override;
    function GetEvaluationCall( const Expression, TypeName, EvalResult: string ): string; override;
    
    function GetVisualizerName: string; override;
    function GetVisualizerDescription: string; override;
  end;

  { TGuidVisualizer }

function TGuidVisualizer.GetEvaluationCall( const Expression, TypeName, EvalResult: string ): string;
begin
  Result := Format( 'GUIDToString(%s)', [Expression] );
end;

function TGuidVisualizer.GetSupportedTypesList: TArray<TCommonDebuggerVisualizerType>;
begin
  Result := ConvertStaticToDynamicArray( GuidVisualizerTypes );
end;

function TGuidVisualizer.GetVisualizerDescription: String;
begin
  Result := GuidVisualizerDescription;
end;

function TGuidVisualizer.GetVisualizerName: String;
begin
  Result := GuidVisualizerName;
end;

var
  StdVisualizer: IOTADebuggerVisualizer;

procedure Register;
var
  DebuggerServices: IOTADebuggerServices;
begin
  if Supports( BorlandIDEServices, IOTADebuggerServices, DebuggerServices ) then
  begin
    StdVisualizer := TGuidVisualizer.Create;
    DebuggerServices.RegisterDebugVisualizer( StdVisualizer );
  end;
end;

procedure RemoveVisualizer;
var
  DebuggerServices: IOTADebuggerServices;
begin
  if Supports( BorlandIDEServices, IOTADebuggerServices, DebuggerServices ) then
  begin
    DebuggerServices.UnregisterDebugVisualizer( StdVisualizer );
    StdVisualizer := nil;
  end;
end;

initialization

finalization

RemoveVisualizer;

end.
