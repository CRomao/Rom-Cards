unit Controller.Movement;

interface

uses
Model.Movement, Model.Card, System.Generics.Collections;

type

  TControllerMovement = class
    private
      class var FListMovement: TList<TModelMovement>;
      class var FLastCardMoved: TModelCard;
    public
      class function GetInstance: TList<TModelMovement>;
      class procedure SetMovement(AMovement: TModelMovement);
      class procedure CleanMemory;
      class procedure SetLastCardMoved(ACard: TModelCard);
      class function GetLastCardMoved: TModelCard;
      class function GetLastMovement: TModelMovement;
  end;

implementation

{ TControllerMovement }

class procedure TControllerMovement.CleanMemory;
var
  I: integer;
begin
  for I := 0 to Pred(GetInstance.Count) do
    GetInstance.Items[I].Free;
  GetInstance.Free;
  FListMovement:= nil;
end;
class function TControllerMovement.GetInstance: TList<TModelMovement>;
var
  LMovement: TModelMovement;
begin
  if not Assigned(FListMovement) then
  begin
    FListMovement:= TList<TModelMovement>.Create;
    LMovement:= TModelMovement.Create;
    LMovement.NEXT_MOVIMENT:= nil;
    LMovement.PREVIOUS_MOVEMENT:= nil;
    LMovement.CARD:= nil;
    LMovement.PREVIOUS_CARD:= nil;
    LMovement.HEAD_STACK_MOVEMENT:= True;
    FListMovement.Add(LMovement);
  end;
  Result:= FListMovement;
end;
class function TControllerMovement.GetLastCardMoved: TModelCard;
begin
  Result:= FLastCardMoved;
end;
class function TControllerMovement.GetLastMovement: TModelMovement;
begin
  Result:= GetInstance.Last;
end;
class procedure TControllerMovement.SetLastCardMoved(ACard: TModelCard);
begin
  FLastCardMoved:= ACard;
end;
class procedure TControllerMovement.SetMovement(AMovement: TModelMovement);
begin
  FListMovement.Add(AMovement);
end;

end.
