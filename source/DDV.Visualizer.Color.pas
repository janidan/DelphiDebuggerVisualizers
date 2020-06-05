unit DDV.Visualizer.Color;

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
  ColorVisualizerTypes: array [0 .. 1] of TCommonDebuggerVisualizerType = ( //
    ( TypeName: 'TColor' ), ( TypeName: 'Graphics::TColor' ) );

resourcestring
  ColorVisualizerName = 'TColor visualizer';
  ColorVisualizerDescription = 'Visualizes a TColor to a human readable format';

type
  TColorVisualizer = class( TCommonDebuggerVisualizer )
  protected
    function GetSupportedTypesList: TArray<TCommonDebuggerVisualizerType>; override;
    function GetReplacementValue( const Expression, TypeName, EvalResult: string ): string; override;

    function GetVisualizerName: string; override;
    function GetVisualizerDescription: string; override;
  end;

implementation

uses
  System.SysUtils,
  Vcl.Graphics;

{ TColorVisualizer }

function TColorVisualizer.GetReplacementValue( const Expression, TypeName, EvalResult: string ): string;
begin
  Result := ColorToString( StrToInt( EvalResult ) );
end;

function TColorVisualizer.GetSupportedTypesList: TArray<TCommonDebuggerVisualizerType>;
begin
  Result := ConvertStaticToDynamicArray( ColorVisualizerTypes );
end;

function TColorVisualizer.GetVisualizerDescription: String;
begin
  Result := ColorVisualizerDescription;
end;

function TColorVisualizer.GetVisualizerName: String;
begin
  Result := ColorVisualizerName;
end;

end.
