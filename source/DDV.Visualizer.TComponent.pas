unit DDV.Visualizer.TComponent;

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
  ComponentVisualizerTypes: array [0 .. 0] of TCommonDebuggerVisualizerType = ( //
    ( TypeName: 'TComponent'; AllDescendants: True ) );

resourcestring
  ComponentVisualizerName = 'TComponent visualizer';
  ComponentVisualizerDescription = 'Visualizes a TComponent to give some more information than all attributes';

type
  TComponentVisualizer = class( TCommonDebuggerEvaluationVisualizer )
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

{ TComponentVisualizer }

function TComponentVisualizer.GetEvaluationCall( const Expression, TypeName, EvalResult: string ): string;
begin
  Result := Expression + '.ToString';
end;

function TComponentVisualizer.GetReplacementValue( const Expression, TypeName, EvalResult: string ): string;
var
  vEvaluatedData: string;
  vName: string;
begin
  // The inherited call will execute the evaluation call - we may also want the standard data from the evaluation,
  // since to string normally only gives the ClassName of the object.
  vEvaluatedData := inherited GetReplacementValue( Expression, TypeName, EvalResult );
  vName := GetEvaluator.ExecuteEvaluation( Expression + '.Name', '<Unnamed>' );
  Result := Format( '%s.%s - %s', [vEvaluatedData, vName, EvalResult] );
end;

function TComponentVisualizer.GetSupportedTypesList: TArray<TCommonDebuggerVisualizerType>;
begin
  Result := ConvertStaticToDynamicArray( ComponentVisualizerTypes );
end;

function TComponentVisualizer.GetVisualizerDescription: String;
begin
  Result := ComponentVisualizerDescription;
end;

function TComponentVisualizer.GetVisualizerName: String;
begin
  Result := ComponentVisualizerName;
end;

end.
