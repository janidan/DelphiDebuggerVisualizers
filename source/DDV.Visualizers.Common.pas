unit DDV.Visualizers.Common;

// Delphi Code Visualizers
// Copyright (c) 2020 Tobias Rörig
// https://github.com/janidan/DelphiDebuggerVisualizers

{* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. *}

interface

uses
  ToolsAPI,
  DDV.Visualizers.CommonOTA,
  DDV.Visualizers.Evaluator;

type
  TCommonDebuggerVisualizerType = record
    TypeName: string;
    AllDescendants: Boolean;
    IsGeneric: Boolean;
  end;

  TCommonDebuggerVisualizer = class( TInterfacedObject, IOTADebuggerVisualizer, IOTADebuggerVisualizer250, IOTADebuggerVisualizerValueReplacer )
  protected
    function ConvertStaticToDynamicArray<T>( const aStatic: array of T ): TArray<T>;
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
    procedure GetSupportedType( Index: Integer; var TypeName: string; var AllDescendants: Boolean ); overload; virtual;
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
    procedure GetSupportedType( Index: Integer; var TypeName: string; var AllDescendants: Boolean; var IsGeneric: Boolean ); overload; virtual;
    {$ENDREGION 'IOTADebuggerVisualizer250 interface implementation'}
    {$REGION 'IOTADebuggerVisualizerValueReplacer interface implementation'}
    { This is the simplest form of a debug visualizer.  With it, you can replace
      the value returned by the evaluator with a more meaningful value.  The
     replacement value will appear in the normal debugger UI (i.e. Evaluator
     Tooltips, Watch View, Locals View, Evaluate/Modify dialog,
     Debug Inspector View).
     There can be only one active IOTADebuggerVisualizerValueReplacer per type }
    function GetReplacementValue( const Expression, TypeName, EvalResult: string ): string; virtual;
    {$ENDREGION 'IOTADebuggerVisualizerValueReplacer interface implementation'}
  end;

  TCommonDebuggerEvaluationVisualizer = class( TCommonDebuggerVisualizer )
  private
    FDebuggerEvaluator: IDDVDebuggerEvaluator;
  protected
    function GetEvaluator: IDDVDebuggerEvaluator;
    function GetEvaluationCall( const Expression, TypeName, EvalResult: string ): string; virtual; abstract;
    function GetReplacementValue( const Expression, TypeName, EvalResult: string ): string; override;
  end;

implementation

uses
  System.SysUtils;

{ TCommonDebuggerVisualizer }

function TCommonDebuggerVisualizer.ConvertStaticToDynamicArray<T>( const aStatic: array of T ): TArray<T>;
var
  i: Integer;
begin
  SetLength( Result, Length( aStatic ) );
  for i := 0 to high( aStatic ) do
    Result[i] := aStatic[i];
end;

function TCommonDebuggerVisualizer.GetReplacementValue( const Expression, TypeName, EvalResult: string ): string;
begin
  Result := Format( '%s : %s = %s', [Expression, TypeName, EvalResult] );
end;

procedure TCommonDebuggerVisualizer.GetSupportedType( Index: Integer; var TypeName: string; var AllDescendants, IsGeneric: Boolean );
var
  vTypeInfo: TCommonDebuggerVisualizerType;
begin
  vTypeInfo := GetSupportedTypesList[Index];
  TypeName := vTypeInfo.TypeName;
  AllDescendants := vTypeInfo.AllDescendants;
  IsGeneric := vTypeInfo.IsGeneric;
end;

procedure TCommonDebuggerVisualizer.GetSupportedType( Index: Integer; var TypeName: string; var AllDescendants: Boolean );
var
  vTypeInfo: TCommonDebuggerVisualizerType;
begin
  vTypeInfo := GetSupportedTypesList[Index];
  TypeName := vTypeInfo.TypeName;
  AllDescendants := vTypeInfo.AllDescendants;
end;

function TCommonDebuggerVisualizer.GetSupportedTypeCount: Integer;
begin
  Result := Length( GetSupportedTypesList );
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

function TCommonDebuggerEvaluationVisualizer.GetEvaluator: IDDVDebuggerEvaluator;
begin
  if not Assigned( FDebuggerEvaluator ) then
    FDebuggerEvaluator := TDebuggerEvaluator.Create;
  Result := FDebuggerEvaluator;
end;

function TCommonDebuggerEvaluationVisualizer.GetReplacementValue( const Expression, TypeName, EvalResult: string ): string;
begin
  // if the evaluation has already resulted in "nil" there is no point in executing an additonal evaluation call.
  // Even worse - the error of an invalid call to the evaluator only clutters the result.
  if ( EvalResult = 'nil' ) then
    Exit( 'nil' );

  // If the evaluation is not successfull we will preappend the origninal evaluation result to the error message, so that the user
  // has the "best" result in the debugger.
  if not GetEvaluator.TryExecuteEvaluation( GetEvaluationCall( Expression, TypeName, EvalResult ), Result ) then
    Result := Format( '%s (Eval: %s)', [EvalResult, Result] );
end;

end.
