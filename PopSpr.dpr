program PopSpr;

uses
  Forms,
  uPopSpr in 'uPopSpr.pas' {PopSprExt};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Pop Sprite Extractor';
  Application.CreateForm(TPopSprExt, PopSprExt);
  Application.Run;
end.
