unit DDV.Visualizer.TObject;

// Delphi Code Visualizers
// Copyright (c) 2020 Tobias Rörig
// https://github.com/janidan/DelphiDebuggerVisualizers

{* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. *}

interface

uses
  DDV.Visualizers.Common;

const
  ObjectVisualizerTypes: array [0 .. 0] of TCommonDebuggerVisualizerType = ( //
    ( TypeName: 'TObject'; AllDescendants: True ) );

resourcestring
  ObjectVisualizerName = 'TObject visualizer';
  ObjectVisualizerDescription = 'Visualizes a TObject to give some more information than ()';

type
  TObjectVisualizer = class( TCommonDebuggerEvaluationVisualizer )
  protected
    function GetSupportedTypesList: TArray<TCommonDebuggerVisualizerType>; override;
    function GetEvaluationCall( const Expression, TypeName, EvalResult: string ): string; override;
    function GetReplacementValue( const Expression, TypeName, EvalResult: string ): string; override;

    function GetVisualizerName: string; override;
    function GetVisualizerDescription: string; override;
  end;

implementation

uses
  System.SysUtils;

{ TObjectVisualizer }

function TObjectVisualizer.GetEvaluationCall( const Expression, TypeName, EvalResult: string ): string;
begin
  Result := Expression + '.ToString';
end;

function TObjectVisualizer.GetReplacementValue( const Expression, TypeName, EvalResult: string ): string;
var
  vEvaluatedData: string;
begin
  // The inherited call will execute the evaluation call - we may also want the standard data from the evaluation,
  // since to string normally only gives the ClassName of the object.
  vEvaluatedData := inherited GetReplacementValue( Expression, TypeName, EvalResult );
  Result := Format( '%s - %s', [vEvaluatedData, EvalResult] );
end;

function TObjectVisualizer.GetSupportedTypesList: TArray<TCommonDebuggerVisualizerType>;
begin
  Result := ConvertStaticToDynamicArray( ObjectVisualizerTypes );
end;

function TObjectVisualizer.GetVisualizerDescription: String;
begin
  Result := ObjectVisualizerDescription;
end;

function TObjectVisualizer.GetVisualizerName: String;
begin
  Result := ObjectVisualizerName;
end;

end.
