unit View.Ranking;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Ani, FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Effects, FMX.ListView, FireDAC.Comp.Client, System.StrUtils, REST.Types,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, system.JSON,
  System.DateUtils, System.Generics.Collections;

type
  TViewRanking = class(TFrame)
    lytContainer: TLayout;
    rtgContainer: TRectangle;
    lytOptions: TLayout;
    rtgOptions: TRectangle;
    Layout1: TLayout;
    rtgTopClose: TRectangle;
    Rectangle9: TRectangle;
    rtgClose: TRectangle;
    imgClose: TImage;
    Animation: TFloatAnimation;
    lytContent: TLayout;
    lvMusicas: TListView;
    lblFirst: TLabel;
    RESTClient: TRESTClient;
    Req: TRESTRequest;
    Res: TRESTResponse;
    lytTopTitle: TLayout;
    lblClassification: TLabel;
    lblNickName: TLabel;
    Label1: TLabel;
    imgRefresh: TImage;
    Line1: TLine;
    procedure lvMusicasScrollViewChange(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
    procedure AnimationFinish(Sender: TObject);
    procedure imgRefreshClick(Sender: TObject);
  private
    FPlayers: TJSONArray;
    FCloseAnimation, FFirstSearch: Boolean;
    FLimit, FOffSet, FPage, FPositionPlayer, FTotalRecords: integer;
    procedure carregarpaginados;
    procedure AddRow(APosition, ANickName, ATimePlayed: string);
    procedure getPlayers;
    procedure ThreadTerminate(Sender: TObject);
    procedure ProcessarGET;
    procedure ProcessarGETErro(Sender: TObject);
    procedure GetTotalRecords;
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

procedure TViewRanking.AnimationFinish(Sender: TObject);
begin
  if FCloseAnimation then
  begin
    if Assigned(FPlayers) then
    begin
      FPlayers.DisposeOf;
      FPlayers := nil;
    end;
    Self.Free;
  end
  else
  begin
    FLimit:= 6;
    FOffSet:= 0;
    FPage:= 1;
    FPositionPlayer:= 0;
    FTotalRecords:= 0;
    FFirstSearch:= True;
    lytContent.Visible:= True;
    getPlayers;
  end;
end;

procedure TViewRanking.carregarpaginados;
var
  vThreadLoading: TThread;
begin
  vThreadLoading := TThread.CreateAnonymousThread(
    procedure
    begin
      for var I:=0 to FPlayers.Count - 1 do
      begin
        inc(FPositionPlayer);
        TThread.Synchronize(TThread.CurrentThread,
          procedure
          begin
            AddRow(FPositionPlayer.ToString,
                FPlayers.Items[i].GetValue<string>('nick_name', ''),
                FPlayers.Items[i].GetValue<string>('time_played', ''));
          end);
      end;
    end);

  vThreadLoading.OnTerminate := ThreadTerminate;
  vThreadLoading.Start;
end;

procedure TViewRanking.ThreadTerminate(Sender: TObject);
begin
  lvMusicas.EndUpdate;
end;

procedure TViewRanking.AddRow(APosition, ANickName, ATimePlayed: string);
var
  item: TListViewItem;
begin
  item := lvMusicas.Items.Add;

  with item do
  begin
    Height := 55;
    TListItemText(Objects.FindDrawable('txtPosition')).Text := APosition+'º';
    TListItemText(Objects.FindDrawable('txtNickName')).Text := ANickName;
    TListItemText(Objects.FindDrawable('txtTimePlayed')).Text := ATimePlayed;
  end;

  item.Tag:= FPositionPlayer;
end;

procedure TViewRanking.lvMusicasScrollViewChange(Sender: TObject);
var
  R: TRectF;
begin
if TListView(Sender).ItemCount > 0 then // Just in case...
  begin
    // Capturar o ultimo item da list view
    R := TListView(Sender).GetItemRect(TListView(Sender).ItemCount - 1);
    // Comparar se o bottom do ultimo item é igual ao height do list view
    if R.Bottom = TListView(Sender).Height then
    begin
      if (FTotalRecords <> FPositionPlayer) then
      begin
        Inc(FPage);
        FOffSet:= FLimit * (FPage - 1);
        getPlayers;
      end;
    end;
  end;
end;

procedure TViewRanking.getPlayers;
begin
  try
    if FFirstSearch then
    begin
      FFirstSearch:= False;
      RESTClient.BaseURL:='https://iglkytpfpsbuivxvksog.supabase.co/rest/v1/ranking?select=*';
      Req.ExecuteAsync(GetTotalRecords, true, true, ProcessarGETErro);
    end
    else
    begin
      RESTClient.BaseURL:=
      'https://iglkytpfpsbuivxvksog.supabase.co/rest/v1/ranking?select=*&order=time_played'+
      '&limit='+FLimit.ToString+'&offset='+FOffSet.ToString;
      Req.ExecuteAsync(ProcessarGET, true, true, ProcessarGETErro);
    end;

  except
    on ex: Exception do
    begin
      ShowMessage('Erro ao listar o ranking: ' + ex.Message);
    end;
  end;
end;

procedure TViewRanking.ProcessarGETErro(Sender: TObject);
begin
  if Assigned(Sender) and (Sender is Exception) then
  begin
    ShowMessage(Exception(Sender).Message);
  end;
end;

procedure TViewRanking.ProcessarGET;
var
  json: string;
begin
  if Req.Response.StatusCode <> 200 then
  begin
    ShowMessage(Req.Response.Content);
  end
  else
  begin
    if Assigned(FPlayers) then
    begin
      FPlayers.DisposeOf;
      FPlayers := nil;
    end;
    json := Req.Response.JSONValue.ToString;
    FPlayers:= TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(json), 0) as TJSONArray;
    lvMusicas.BeginUpdate;
    carregarpaginados;
  end;
end;

procedure TViewRanking.GetTotalRecords;
var
  json: string;
begin
  if Req.Response.StatusCode <> 200 then
  begin
    ShowMessage(Req.Response.Content);
  end
  else
  begin
    if Assigned(FPlayers) then
    begin
      FPlayers.DisposeOf;
      FPlayers := nil;
    end;
    json := Req.Response.JSONValue.ToString;
    FPlayers:= TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(json), 0) as TJSONArray;
    FTotalRecords:= FPlayers.Count;
    getPlayers;
  end;
end;

procedure TViewRanking.imgCloseClick(Sender: TObject);
begin
  Animation.Enabled:= False;
  FCloseAnimation:= True;
  lytContent.Visible:= False;
  Animation.Inverse:= True;
  Animation.Enabled:= True;
end;

procedure TViewRanking.imgRefreshClick(Sender: TObject);
begin
  FOffSet:= 0;
  FPage:= 1;
  FPositionPlayer:= 0;
  FTotalRecords:= 0;
  FFirstSearch:= True;
  lvMusicas.ScrollTo(0);
  lvMusicas.Items.Clear;
  getPlayers;
end;

end.
