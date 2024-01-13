unit Model.Stack;

interface

uses
  Model.Card;

type
  TStack = class
    private
      FCARD: TCard;
    public
      property CARD: TCard read FCARD write FCARD;
  end;

implementation

end.
