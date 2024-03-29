unit Controller.Stack;

interface

uses
  Model.Stack,
  Model.Card,
  System.SysUtils,
  System.UITypes,
  FMX.Types,
  System.Generics.Collections;

type

  TControllerStacks = class
    private
      class var FListStack: TList<TModelStack>;
      class function GetImageAssemblyStack(AStackType: TStackType): string;
      class function FindFirstCardVisible(ACard: TModelCard): TModelCard; static;
    public
      class function GetInstance: TList<TModelStack>;
      class procedure InitializeHeadStack;
      class procedure InitialDistribution(ACards: TList<TModelCard>);
      class procedure InitialStockDistribution(ACards: TList<TModelCard>);
      class function GetStack(AStackType: TStackType): TModelStack;
      class procedure PrintCards;
      class procedure CleanMemory;
      class function GetTotalCardsStack(AStackType: TStackType): Integer;
      class function GetLastCardStack(AStackType: TStackType): TModelCard;
      class function FinishedGame: Boolean;
      class function GetTip: TList<string>;
  end;

implementation

{ TControllerStacks }

class procedure TControllerStacks.InitializeHeadStack;
var
  I, J: integer;
  LStack: TModelStack;
begin
  J:= 0;

  for I:= Ord(tstStack1) to Ord(tstAssemblySpade) do
  begin
    LStack:= TModelStack.Create;
    LStack.CARD:= TModelCard.Create(nil);
    LStack.CARD.COLOR:= tccNone;
    LStack.CARD.STACK_TYPE:= TStackType(I);

    if (I >= Ord(tstAssemblyHeart)) then //define the suit of head assembly for receive the cards
    begin
      LStack.CARD.SUIT_CARD:= TSuitCard(J);
      Inc(J);
    end
    else
      LStack.CARD.SUIT_CARD:= tscNone;

    LStack.CARD.Size.Height:= 70;
    LStack.CARD.Size.Width:= 50;
    LStack.CARD.VISIBLE:= True;
    LStack.CARD.PREVIOUS_CARD:= nil;
    LStack.CARD.NEXT_CARD:= nil;
    LStack.CARD.VALUE:= 0;
    GetInstance.Add(LStack);
  end;
end;

class procedure TControllerStacks.initialDistribution(ACards: TList<TModelCard>);
var
  tam, i, lim, j, cont: integer;
  aux, aux2: TModelCard;
begin
  tam:= 51;
  lim:= 6;
  j:=0;
  cont:=1;

  for i:=0 to lim do
  begin
    aux:= GetInstance.Items[i].CARD;
    while (j < cont) do
    begin
      aux2 := aux;
      aux.NEXT_CARD:= ACards.Items[tam];
      aux:= aux.NEXT_CARD;

      aux.STACK_TYPE:= aux2.STACK_TYPE;

      aux.PREVIOUS_CARD:= aux2;
      aux2.AddObject(aux);
      Dec(tam);
      Inc(j);
    end;
    Inc(cont);
    j:=0;
    aux.VISIBLE:= True;
  end;
end;

class procedure TControllerStacks.InitialStockDistribution(ACards: TList<TModelCard>);
var
  i: integer;
  auxEstoque: TModelCard;
begin
  auxEstoque:= GetInstance.Items[Ord(tstStock)].CARD;
  for i := 0 to 23 do
  begin
    //alterações nas cartas do estoque
    ACards.Items[i].VISIBLE:= True;
    ACards.Items[i].Bitmap.LoadFromFile(ACards.Items[i].IMAGE_CARD_DEFAULT_LOCATION);
    ACards.Items[i].Padding.Top:= 0;
    ACards.Items[i].STACK_TYPE:= tstStock;
    auxEstoque.AddObject(ACards.Items[i]);

    auxEstoque.NEXT_CARD:= ACards.Items[i];
    ACards.Items[i].PREVIOUS_CARD:= auxEstoque;
    auxEstoque:= ACards.Items[i];
  end;
end;

class procedure TControllerStacks.PrintCards;
var
  aux: TModelCard;
  lim, i: integer;
begin
  lim:= 6;

  for i := 0 to lim do
  begin
    aux:= GetInstance.Items[i].CARD.NEXT_CARD;
    while Assigned(aux) do
    begin
      if not aux.VISIBLE then
        aux.Bitmap.LoadFromFile(aux.IMAGE_CARD_DEFAULT_LOCATION);

      aux:= aux.NEXT_CARD;
    end;
  end;
end;

class procedure TControllerStacks.CleanMemory;
var
  I: integer;
begin
  for I := 0 to Pred(GetInstance.Count) do
    GetInstance.Items[I].Free;

  GetInstance.Free;
  FListStack:= nil;
end;

class function TControllerStacks.FinishedGame: Boolean;
var
  I, TotalCardsAssembly: integer;
begin
  TotalCardsAssembly:= 0;

  for I := Ord(tstAssemblyHeart) to Ord(tstAssemblySpade) do
    TotalCardsAssembly:= TotalCardsAssembly + GetTotalCardsStack(TStackType(I));

  Result:= TotalCardsAssembly = 52;
end;

class function TControllerStacks.GetImageAssemblyStack(AStackType: TStackType): string;
begin
  Result:= ExtractFilePath(ParamStr(0))+'/img/cards/stack/';
  case AStackType of
    tstAssemblyHeart:Result:= Result + 'heart.png';
    tstAssemblyDiamond:Result:= Result + 'diamond.png';
    tstAssemblyClub:Result:= Result + 'club.png';
    tstAssemblySpade:Result:= Result + 'spade.png';
  end;
end;

class function TControllerStacks.GetLastCardStack(AStackType: TStackType): TModelCard;
begin
  Result:= GetStack(AStackType).CARD;

  while Assigned(Result.NEXT_CARD) do
    Result:= Result.NEXT_CARD;
end;

class function TControllerStacks.GetInstance: TList<TModelStack>;
begin
  if not Assigned(FListStack) then
    FListStack:= TList<TModelStack>.Create;

  Result:= FListStack;
end;

class function TControllerStacks.GetStack(AStackType: TStackType): TModelStack;
begin
  Result:= GetInstance.Items[Ord(AStackType)];
end;

class function TControllerStacks.FindFirstCardVisible(ACard: TModelCard): TModelCard;
begin
  Result:= ACard;

  while Assigned(Result.NEXT_CARD) do
  begin
    Result:= Result.NEXT_CARD;

    if Result.VISIBLE then
      break;
  end;
end;

class function TControllerStacks.GetTip: TList<string>;
var
  I, J: integer;
  LCardMove, LCardReceive: TModelCard;
begin
  Result:= TList<string>.Create;

  for I := Ord(tstStack1) to Ord(tstStack7) do   //stack for stack
  begin
    LCardMove:= FindFirstCardVisible(GetStack(TStackType(I)).CARD);

    J:= 0;
    if (J = I) then
      Inc(J);

    while((J <> I) and (J<7)) do
    begin
      LCardReceive:= GetLastCardStack(TStackType(J));

      if Assigned(LCardMove) and Assigned(LCardReceive) then
      begin
        if ((LCardMove.COLOR <> LCardReceive.COLOR) and ((LCardMove.VALUE + 1) =  LCardReceive.VALUE) and (LCardMove.VALUE <> 13) and (LCardMove.VALUE > 0)) then
        begin
          Result.Add(LCardMove.IMAGE_CARD_LOCATION);
          Result.Add(LCardReceive.IMAGE_CARD_LOCATION);
          exit;
        end
        else
        if (LCardMove.VALUE = 13) and (LCardReceive.VALUE = 0) and (LCardMove.PREVIOUS_CARD.VALUE > 0) then
        begin
          Result.Add(LCardMove.IMAGE_CARD_LOCATION);
          exit;
        end;
      end;

      Inc(J);

      if (J = I) then
        Inc(J);
    end;
  end;

  for I := Ord(tstStack1) to Ord(tstStack7) do   //stack for assembly
  begin
    LCardMove:= GetLastCardStack(TStackType(I));

    for J := Ord(tstAssemblyHeart) to Ord(tstAssemblySpade) do
    begin
      LCardReceive:= GetLastCardStack(TStackType(J));

      if Assigned(LCardMove) and Assigned(LCardReceive) then
      begin
        if ((LCardMove.SUIT_CARD = LCardReceive.SUIT_CARD) and ((LCardMove.VALUE - 1) =  LCardReceive.VALUE) and (LCardMove.VALUE > 0)) then
        begin
          Result.Add(LCardMove.IMAGE_CARD_LOCATION);

          if (LCardReceive.VALUE = 0) then
            Result.Add(GetImageAssemblyStack(LCardReceive.STACK_TYPE))
          else
            Result.Add(LCardReceive.IMAGE_CARD_LOCATION);

          exit;
        end;
      end;
    end;
  end;

  //discard for assembly
  LCardMove:= GetLastCardStack(tstDiscard);

  for J := Ord(tstAssemblyHeart) to Ord(tstAssemblySpade) do
  begin
    LCardReceive:= GetLastCardStack(TStackType(J));

    if Assigned(LCardMove) and Assigned(LCardReceive) then
    begin
      if ((LCardMove.SUIT_CARD = LCardReceive.SUIT_CARD) and ((LCardMove.VALUE - 1) =  LCardReceive.VALUE) and (LCardMove.VALUE > 0)) then
      begin
        Result.Add(LCardMove.IMAGE_CARD_LOCATION);

        if (LCardReceive.VALUE = 0) then
          Result.Add(GetImageAssemblyStack(LCardReceive.STACK_TYPE))
        else
          Result.Add(LCardReceive.IMAGE_CARD_LOCATION);

        exit;
      end;
    end;
  end;

  //discard for stack
  LCardMove:= GetLastCardStack(tstDiscard);

  for J := Ord(tstStack1) to Ord(tstStack7) do
  begin
    LCardReceive:= GetLastCardStack(TStackType(J));

    if Assigned(LCardMove) and Assigned(LCardReceive) then
    begin
      if ((LCardMove.COLOR <> LCardReceive.COLOR) and ((LCardMove.VALUE + 1) =  LCardReceive.VALUE) and (LCardMove.VALUE <> 13) and (LCardMove.VALUE > 0)) then
      begin
        Result.Add(LCardMove.IMAGE_CARD_LOCATION);
        Result.Add(LCardReceive.IMAGE_CARD_LOCATION);
        exit;
      end
      else
      if (LCardMove.VALUE = 13) and (LCardReceive.VALUE = 0) and (LCardMove.PREVIOUS_CARD.VALUE > 0) then
      begin
        Result.Add(LCardMove.IMAGE_CARD_LOCATION);
        exit;
      end;
    end;
  end;
end;

class function TControllerStacks.GetTotalCardsStack(AStackType: TStackType): Integer;
var
  aux: TModelCard;
begin
  Result:= 0;
  aux:= GetStack(AStackType).CARD;

  while Assigned(aux.NEXT_CARD) do
  begin
    Inc(Result);
    aux:= aux.NEXT_CARD;
  end;
end;

end.
