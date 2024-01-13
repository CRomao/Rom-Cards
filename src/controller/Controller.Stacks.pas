unit Controller.Stacks;

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
      class var FListStack: TList<TStack>;
      class function GetImageAssemblyStack(AStackID: integer): string;
    public
      class function GetListStack: TList<TStack>;
      class procedure InitializeHeadStack;
      class procedure InitialDistribution(ACards: TList<TCard>);
      class procedure InitialStockDistribution(ACards: TList<TCard>);
      class function GetStack(AStackID: integer): TStack;
      class procedure PrintCards;
      class procedure CleanMemory;
      class function GetTotalCardsStack(AStackID: integer): Integer;
      class function GetLastCardStack(AStackID: integer): TCard;
      class function FinishedGame: Boolean;
      class function GetTip: TList<string>;
  end;

implementation

{ TControllerStacks }

class procedure TControllerStacks.InitializeHeadStack;
var
  I, J: integer;
  LStack: TStack;
begin
  J:= 0;

  for I:= 0 to 12 do
  begin
    LStack:= TStack.Create;
    LStack.CARD:= TCard.Create(nil);
    LStack.CARD.COLOR:= tccNone;
    LStack.CARD.STACK_ID:= I;

    if (I >= 9) then //define the suit of head assembly for receive the cards
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
    GetListStack.Add(LStack);
  end;
end;

class procedure TControllerStacks.initialDistribution(ACards: TList<TCard>);
var
  tam, i, lim, j, cont: integer;
  aux, aux2: TCard;
begin
  tam:= 51;
  lim:= 6;
  j:=0;
  cont:=1;

  for i:=0 to lim do
  begin
    aux:= GetListStack.Items[i].CARD;
    while (j < cont) do
    begin
      aux2 := aux;
      aux.NEXT_CARD:= ACards.Items[tam];
      aux:= aux.NEXT_CARD;

      aux.STACK_ID:= aux2.STACK_ID;

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

class procedure TControllerStacks.InitialStockDistribution(ACards: TList<TCard>);
var
  i: integer;
  auxEstoque: TCard;
begin
  auxEstoque:= GetListStack.Items[7].CARD;
  for i := 0 to 23 do
  begin
    //alterações nas cartas do estoque
    ACards.Items[i].VISIBLE:= True;
    ACards.Items[i].Bitmap.LoadFromFile(ACards.Items[i].IMAGE_CARD_DEFAULT_LOCATION);
    ACards.Items[i].Padding.Top:= 0;
    ACards.Items[i].STACK_ID:= 7;
    auxEstoque.AddObject(ACards.Items[i]);

    auxEstoque.NEXT_CARD:= ACards.Items[i];
    ACards.Items[i].PREVIOUS_CARD:= auxEstoque;
    auxEstoque:= ACards.Items[i];
  end;
end;

class procedure TControllerStacks.PrintCards;
var
  aux: TCard;
  lim, i: integer;
begin
  lim:= 6;

  for i := 0 to lim do
  begin
    aux:= GetListStack.Items[i].CARD.NEXT_CARD;
    if not (aux = nil) then
    begin
      while not (aux = nil) do
      begin
        if not aux.VISIBLE then
          aux.Bitmap.LoadFromFile(aux.IMAGE_CARD_DEFAULT_LOCATION);

        aux:= aux.NEXT_CARD;
      end;
    end;
  end;
end;

class procedure TControllerStacks.CleanMemory;
var
  I: integer;
begin
  for I := 0 to Pred(GetListStack.Count) do
    GetListStack.Items[I].Free;

  GetListStack.Free;
  FListStack:= nil;
end;

class function TControllerStacks.FinishedGame: Boolean;
var
  I, TotalCardsAssembly: integer;
begin
  TotalCardsAssembly:= 0;

  for I := 9 to 12 do
    TotalCardsAssembly:= TotalCardsAssembly + GetTotalCardsStack(I);

  Result:= TotalCardsAssembly = 52;
end;

class function TControllerStacks.GetImageAssemblyStack(AStackID: integer): string;
begin
  Result:= ExtractFilePath(ParamStr(0))+'/img/cards/stack/';
  case AStackID of
     9:Result:= Result + 'heart.png';
    10:Result:= Result + 'diamond.png';
    11:Result:= Result + 'club.png';
    12:Result:= Result + 'spade.png';
  end;
end;

class function TControllerStacks.GetLastCardStack(AStackID: integer): TCard;
begin
  Result:= GetStack(AStackID).CARD;

  while (Result.NEXT_CARD <> nil) do
    Result:= Result.NEXT_CARD;
end;

class function TControllerStacks.GetListStack: TList<TStack>;
begin
  if (FListStack = nil) then
    FListStack:= TList<TStack>.Create;

  Result:= FListStack;
end;

class function TControllerStacks.GetStack(AStackID: integer): TStack;
begin
  Result:= GetListStack.Items[AStackID];
end;

class function TControllerStacks.GetTip: TList<string>;
var
  I, J: integer;
  aux, aux2: TCard;
  //aux = carta que vai ser movida
  //aux2 = carta que vai receber a carta movida
begin
  Result:= TList<string>.Create;

  for I := 0 to 6 do   //stack for stack
  begin
    aux:= GetStack(I).CARD;

    while (aux.NEXT_CARD <> nil) do
    begin
      aux:= aux.NEXT_CARD;

      if aux.VISIBLE then
        break;
    end;

    J:= 0;
    if (J = I) then
      Inc(J);

    while((J <> I) and (J<7)) do
    begin
      aux2:= GetStack(J).CARD;
      while (aux2.NEXT_CARD <> nil ) do
        aux2:= aux2.NEXT_CARD;

      if (aux <> nil) and (aux2 <> nil) then
      begin
        if ((aux.COLOR <> aux2.COLOR) and ((aux.VALUE + 1) =  aux2.VALUE) and (aux.VALUE <> 13) and (aux.VALUE > 0)) then
        begin
          Result.Add(aux.IMAGE_CARD_LOCATION);
          Result.Add(aux2.IMAGE_CARD_LOCATION);
          exit;
        end
        else
        if (aux.VALUE = 13) and (aux2.VALUE = 0) and (aux.PREVIOUS_CARD.VALUE > 0) then
        begin
          Result.Add(aux.IMAGE_CARD_LOCATION);
          exit;
        end;
      end;

      Inc(J);

      if (J = I) then
        Inc(J);
    end;
  end;

  for I := 0 to 6 do   //stack for assembly
  begin
    aux:= GetStack(I).CARD;

    while (aux.NEXT_CARD <> nil) do
    begin
      aux:= aux.NEXT_CARD;

      {if aux.VISIBLE then
        break;}
    end;

    for J := 9 to 12 do
    begin
      aux2:= GetStack(J).CARD;
      while (aux2.NEXT_CARD <> nil ) do
        aux2:= aux2.NEXT_CARD;

      if (aux <> nil) and (aux2 <> nil) then
      begin
        if ((aux.SUIT_CARD = aux2.SUIT_CARD) and ((aux.VALUE - 1) =  aux2.VALUE) and (aux.VALUE > 0)) then
        begin
          Result.Add(aux.IMAGE_CARD_LOCATION);

          if (aux2.VALUE = 0) then
            Result.Add(GetImageAssemblyStack(aux2.STACK_ID))
          else
            Result.Add(aux2.IMAGE_CARD_LOCATION);

          exit;
        end;
      end;
    end;
  end;

  //discard for assembly
  aux:= GetStack(8).CARD;

  while (aux.NEXT_CARD <> nil) do
    aux:= aux.NEXT_CARD;


  for J := 9 to 12 do
  begin
    aux2:= GetStack(J).CARD;
    while (aux2.NEXT_CARD <> nil ) do
      aux2:= aux2.NEXT_CARD;

    if (aux <> nil) and (aux2 <> nil) then
    begin
      if ((aux.SUIT_CARD = aux2.SUIT_CARD) and ((aux.VALUE - 1) =  aux2.VALUE) and (aux.VALUE > 0)) then
      begin
        Result.Add(aux.IMAGE_CARD_LOCATION);

        if (aux2.VALUE = 0) then
          Result.Add(GetImageAssemblyStack(aux2.STACK_ID))
        else
          Result.Add(aux2.IMAGE_CARD_LOCATION);

        exit;
      end;
    end;
  end;

  //discard for stack
  aux:= GetStack(8).CARD;

  while (aux.NEXT_CARD <> nil) do
    aux:= aux.NEXT_CARD;

  for J := 0 to 6 do
  begin
    aux2:= GetStack(J).CARD;
    while (aux2.NEXT_CARD <> nil ) do
      aux2:= aux2.NEXT_CARD;

    if (aux <> nil) and (aux2 <> nil) then
    begin
      if ((aux.COLOR <> aux2.COLOR) and ((aux.VALUE + 1) =  aux2.VALUE) and (aux.VALUE <> 13) and (aux.VALUE > 0)) then
      begin
        Result.Add(aux.IMAGE_CARD_LOCATION);
        Result.Add(aux2.IMAGE_CARD_LOCATION);
        exit;
      end
      else
      if (aux.VALUE = 13) and (aux2.VALUE = 0) and (aux.PREVIOUS_CARD.VALUE > 0) then
      begin
        Result.Add(aux.IMAGE_CARD_LOCATION);
        exit;
      end;
    end;
  end;
end;

class function TControllerStacks.GetTotalCardsStack(AStackID: integer): Integer;
var
  aux: TCard;
begin
  Result:= 0;
  aux:= GetStack(AStackID).CARD;

  while not (aux.NEXT_CARD = nil) do
  begin
    Inc(Result);
    aux:= aux.NEXT_CARD;
  end;
end;

end.
