{$I M_OPS.PAS}

Unit m_QuickSort;

Interface

Const
  mdlMaxSortSize = 5000;

Type
  TSortMethod = (qAscending, qDescending);

  PQuickSortRec = ^TQuickSortRec;
  TQuickSortRec = Record
    Name : String;
    Ptr  : LongInt;
  End;

  TQuickSort = Class
    Total : Word;
    Data  : Array[1..mdlMaxSortSize] of PQuickSortRec;

    Constructor Create;
    Destructor  Destroy; Override;

    Function    Add  (Name: String; Ptr: LongInt) : Boolean;
    Procedure   Sort (Left, Right: Word; Mode: TSortMethod);
    Procedure   Clear;
  End;

Implementation

Constructor TQuickSort.Create;
Begin
  Inherited Create;

  Total := 0;
End;

Destructor TQuickSort.Destroy;
Begin
  Clear;

  Inherited Destroy;
End;

Procedure TQuickSort.Clear;
Var
  Count : Word;
Begin
  For Count := 1 to Total Do
    Dispose (Data[Count]);

  Total := 0;
End;

Function TQuickSort.Add (Name: String; Ptr: LongInt) : Boolean;
Begin
  Result := False;

  Inc (Total);
  New (Data[Total]);

  If Data[Total] = NIL Then Begin
    Dec (Total);
    Exit;
  End;

  Data[Total]^.Name := Name;
  Data[Total]^.Ptr  := Ptr;

  Result := True;
End;

Procedure TQuickSort.Sort (Left, Right: Word; Mode: TSortMethod);
Var
  Temp   : PQuickSortRec;
  Pivot  : TQuickSortRec;
  Lower  : Word;
  Upper  : Word;
  Middle : Word;
Begin
  If Total = 0 Then Exit;

  Lower  := Left;
  Upper  := Right;
  Middle := (Left + Right) DIV 2;
  Pivot  := Data[Middle]^;

  Repeat
    Case Mode of
      qAscending : Begin
            While Data[Lower]^.Name < Pivot.Name Do Inc(Lower);
            While Pivot.Name < Data[Upper]^.Name Do Dec(Upper);
          End;
      qDescending : Begin
            While Data[Lower]^.Name > Pivot.Name Do Inc(Lower);
            While Pivot.Name > Data[Upper]^.Name Do Dec(Upper);
          End;
    End;

    If Lower <= Upper Then Begin
      Temp        := Data[Lower];
      Data[Lower] := Data[Upper];
      Data[Upper] := Temp;

      Inc (Lower);
      Dec (Upper);
    End;

  Until Lower > Upper;

  If Left  < Upper Then Sort(Left,  Upper, Mode);
  If Lower < Right Then Sort(Lower, Right, Mode);
End;

End.