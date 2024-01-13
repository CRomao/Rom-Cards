unit Controller.Cards;

interface

uses
  Model.Card,
  System.SysUtils,
  System.UITypes, FMX.Types, System.Generics.Collections, System.Types;

type
  TControllerCards = class
    private
      class var FListCards: TList<TCard>;
    public
      class function GetListCard: TList<TCard>;
      class procedure InitializeCards;
      class procedure ShuffleCards;
      class procedure CleanMemory;
  end;

implementation

{ TControllerCards }

class procedure TControllerCards.InitializeCards;
var
  LImagerCardLocation: array of string;
  LCard: TCard;
  I, J: Integer;
begin
  SetLength(LImagerCardLocation, 5);
  LImagerCardLocation[0]:= ExtractFilePath(ParamStr(0))+'/img/cards/heart/';
  LImagerCardLocation[1]:= ExtractFilePath(ParamStr(0))+'/img/cards/diamond/';
  LImagerCardLocation[2]:= ExtractFilePath(ParamStr(0))+'/img/cards/club/';
  LImagerCardLocation[3]:= ExtractFilePath(ParamStr(0))+'/img/cards/spade/';
  LImagerCardLocation[4]:= ExtractFilePath(ParamStr(0))+'/img/cards/default/default.png';

  for I := 0 to 3 do
  begin
    for J := 0 to 12 do
    begin
      LCard:= TCard.Create(nil);

      LCard.PREVIOUS_CARD:= nil;
      LCard.NEXT_CARD:= nil;
      LCard.SUIT_CARD:= TSuitCard(I);
      LCard.VISIBLE:= False;
      LCard.VALUE:= (J+1);
      LCard.COLOR:= TColorCard(Trunc(I/2));
      LCard.IMAGE_CARD_LOCATION:= LImagerCardLocation[I] + (J+1).ToString+'.png';
      LCard.IMAGE_CARD_DEFAULT_LOCATION:= LImagerCardLocation[4];
      LCard.Bitmap.LoadFromFile(LCard.IMAGE_CARD_LOCATION);
      LCard.DragMode:= TDragMode.dmAutomatic;
      LCard.Size.Height:= 70;
      LCard.Size.Width:= 50;
      LCard.Align:= TAlignLayout.Top;
      LCard.Padding.Top:= 23;
      LCard.Cursor:= crHandPoint;

      GetListCard.Add(Lcard);
    end;
  end;
end;

class procedure TControllerCards.ShuffleCards;
var
  LNewPosition, I: integer;
  LCurrentCard: TCard;
begin
  Randomize;

  for I := 0 to 51 do
  begin
    LNewPosition:= Round(random(51));
    LCurrentCard:= GetListCard.Items[I];
    GetListCard.Items[I]:= GetListCard.Items[LNewPosition];
    GetListCard.Items[LNewPosition]:= LCurrentCard;
  end;
end;

class function TControllerCards.GetListCard: TList<TCard>;
begin
  if (FListCards = nil) then
    FListCards:= TList<TCard>.Create;

  Result:= FListCards;
end;

class procedure TControllerCards.CleanMemory;
begin
  GetListCard.Free;
  FListCards:= nil;
end;

end.
