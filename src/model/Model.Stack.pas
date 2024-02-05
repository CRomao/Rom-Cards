unit Model.Stack;

interface

uses
  Model.Card;

type
  TModelStack = class
    private
      FCARD: TModelCard;
    public
      property CARD: TModelCard read FCARD write FCARD;
  end;

implementation

end.
