unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uCloth, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Canvas.MoveTo(0, 0);
  Canvas.LineTo(10, 10);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//   Acanvas := Image1.Picture.Create.Bitmap.Canvas;
//	ctx    = canvas.getContext('2d');

//	canvas.width = canvas.clientWidth;
//	canvas.height = 376;


	boundsx := Self.Width - 1;
	boundsy := Self.Height - 1;

//	ctx.strokeStyle = 'rgba(222,222,222,0.6)';
  ABmp := TBitmap.Create;
  ABmp.width:= ClientWidth;
  ABmp.height:= ClientHeight;
  ACanvasReal := Canvas;
	cloth := TCloth.Create;
//	uCloth.update;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  rect : TRect;
begin
  Amouse.button := Integer(button);
	Amouse.px := amouse.x;
	AMouse.py := amouse.y;
  rect := ABmp.Canvas.ClipRect;
  amouse.x := X - rect.left;
  amouse.y := Y - rect.top;
	amouse.down := true;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  rect : TRect;
begin
  amouse.px := amouse.x;
	amouse.py := amouse.y;
	rect := ABmp.Canvas.ClipRect;
  amouse.x := X - rect.left;
  amouse.y := Y - rect.top;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  amouse.down := false;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  ABmp.width:= ClientWidth;
  ABmp.height:= ClientHeight;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  uCloth.update;
end;

end.
