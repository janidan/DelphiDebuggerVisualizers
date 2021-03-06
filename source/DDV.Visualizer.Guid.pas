unit DDV.Visualizer.Guid;

// Delphi Code Visualizers
// Copyright (c) 2020 Tobias R�rig
// https://github.com/janidan/DelphiDebuggerVisualizers

{* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. *}

interface

uses
  DDV.Visualizers.Common;

const
  GuidVisualizerTypes: array [0 .. 1] of TCommonDebuggerVisualizerType = ( //
    ( TypeName: 'TGUID' ), ( TypeName: 'System::TGUID' ) );

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

implementation

uses
  System.SysUtils;

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

end.
