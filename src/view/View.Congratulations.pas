unit View.Congratulations;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Ani, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit,
  REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, System.JSON;

type
  TViewCongratulations = class(TFrame)
    lytContainer: TLayout;
    rtgContainer: TRectangle;
    lytOptions: TLayout;
    rtgOptions: TRectangle;
    lblTitle: TLabel;
    lytTopClose: TLayout;
    rtgTopClose: TRectangle;
    Rectangle9: TRectangle;
    rtgClose: TRectangle;
    imgClose: TImage;
    Animation: TFloatAnimation;
    lblInformation: TLabel;
    lblNickname: TLabel;
    rtgNo: TRectangle;
    rtgYes: TRectangle;
    RESTClient: TRESTClient;
    Req: TRESTRequest;
    Res: TRESTResponse;
    lblNo: TLabel;
    lblYes: TLabel;
    Label1: TLabel;
    lblElapsedTime: TLabel;
    lblMovementsUndone: TLabel;
    lblTipsUseds: TLabel;
    lblTimeFinal: TLabel;
    lytContents: TLayout;
    lytButtons: TLayout;
    lytNickName: TLayout;
    edtNickName: TEdit;
    procedure rtgNoClick(Sender: TObject);
    procedure AnimationFinish(Sender: TObject);
    procedure rtgYesClick(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
  private
    { Private declarations }
    FCloseAnimation, FCloseAnimationGame: Boolean;
    procedure SaveRankingPlayer;
    procedure CloseAll;
  public
    { Public declarations }
    procedure CalculatedTimeEndGame;
  end;

implementation

uses
  View.Principal;

{$R *.fmx}

procedure TViewCongratulations.AnimationFinish(Sender: TObject);
begin
  if FCloseAnimation then
  begin
    if Assigned(ViewPrincipal) then
      ViewPrincipal.Close;
  end
  else
  if FCloseAnimationGame then
  begin
    if Assigned(ViewPrincipal) then
      ViewPrincipal.Close;
  end
  else
  begin
    ViewPrincipal.Timer.Enabled:= False;
    lblTitle.Visible:= True;
    rtgNo.Visible:= True;
    rtgYes.Visible:= True;
    lblNickname.Visible:= True;
    lblInformation.Visible:= True;
    edtNickName.Visible:= True;
  end;
end;

procedure TViewCongratulations.imgCloseClick(Sender: TObject);
begin
  CloseAll;
end;

procedure TViewCongratulations.rtgNoClick(Sender: TObject);
begin
  CloseAll;
end;

procedure TViewCongratulations.rtgYesClick(Sender: TObject);
begin
  if (edtNickName.Text = EmptyStr) then
    Abort;

  SaveRankingPlayer;
  Animation.Enabled:= False;
  FCloseAnimationGame:= True;
  lytContents.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

procedure TViewCongratulations.CloseAll;
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lytContents.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

procedure TViewCongratulations.CalculatedTimeEndGame;
var
  LSecondsMovements, LSecondsTips: integer;
begin
  LSecondsMovements:= 0;
  LSecondsTips:= 0;

  lblElapsedTime.Text:= lblElapsedTime.Text +  ViewPrincipal.FTempoCronometroText;

  LSecondsMovements:= (ViewPrincipal.FNumberOfMovementsUndone * 2);
  lblMovementsUndone.Text:=
  lblMovementsUndone.Text + ViewPrincipal.FNumberOfMovementsUndone.ToString + ' x 2 = '+
  LSecondsMovements.ToString + ' segundos.';

  LSecondsTips:= (ViewPrincipal.FNumberOfTipsUsed * 4);
  lblTipsUseds.Text:=
  lblTipsUseds.Text + ViewPrincipal.FNumberOfTipsUsed.ToString + ' x 4 = '+
  LSecondsTips.ToString + ' segundos.';

  ViewPrincipal.FTempoCronometro:= ViewPrincipal.FTempoCronometro + LSecondsMovements + LSecondsTips;
  ViewPrincipal.CalculatedTimeRunning;
  lblTimeFinal.Text:= lblTimeFinal.Text + ViewPrincipal.FTempoCronometroText;
end;


procedure TViewCongratulations.SaveRankingPlayer;
var
  LPlayer: TJSONObject;
begin
  try
    try
      Req.Body.ClearBody;

      LPlayer:= TJSONObject.Create.
                      AddPair('nick_name', edtNickName.Text).
                      AddPair('time_played', ViewPrincipal.FTempoCronometroText);

      Req.Body.Add((LPlayer.ToString),ContentTypeFromString('application/json'));
      Req.Execute;

      if (Req.Response.StatusCode <> 200) and (Req.Response.StatusCode <> 201) then
        ShowMessage('Erro ao enviar para o ranking')
      else
      begin
        ShowMessage('Enviado para o ranking!');
      end;
    except
      on ex: Exception do
      begin
        ShowMessage('Erro ao enviar para o ranking. Motivo: '+ex.Message);
      end;
    end;
  finally
    LPlayer.Free;
  end;
end;

end.
