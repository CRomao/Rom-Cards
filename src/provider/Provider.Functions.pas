unit Provider.Functions;

interface

  procedure CloseGame;
  procedure InitGame;
  procedure SplitCardsToStack(Sender: TOBject; AIndexStack: integer);

implementation

uses
  Controller.Card, Controller.Stack, Controller.Movement, Model.Card, FMX.Objects, View.Principal;

procedure CloseGame;
begin
  TControllerCards.CleanMemory;
  TControllerStacks.CleanMemory;
  TControllerMovement.CleanMemory;
end;

procedure InitGame;
begin
  //cards
  TControllerCards.InitializeCards;
  TControllerCards.ShuffleCards;

  //stacks
  TControllerStacks.InitializeHeadStack;
  TControllerStacks.InitialDistribution(TControllerCards.GetInstance);
  TControllerStacks.InitialStockDistribution(TControllerCards.GetInstance);
  TControllerStacks.PrintCards;
end;

procedure SplitCardsToStack(Sender: TOBject; AIndexStack: integer);
begin
  if (Sender is TRectangle) then
  TRectangle(Sender).AddObject(TControllerStacks.GetInstance.Items[AIndexStack].CARD)
  else
    TImage(Sender).AddObject(TControllerStacks.GetInstance.Items[AIndexStack].CARD);
end;

end.
