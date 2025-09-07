page 80200 "IFS RD Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "IFS RD Setup";
    AboutText = 'Setup for IFS RD VAT Service';
    AboutTitle = 'IFS RD VAT Service Setup';
    Caption = 'IFS RD VAT Service Setup';
    layout
    {
        area(Content)
        {
            group(Setup)
            {
                field("Moo Display"; Rec."Moo Display")
                {
                    ToolTip = 'แสดงผลหมู่ที่ (MooNumber) ด้วยค่าใน Field นี้';
                }
                field("Soi Display"; Rec."Soi Display")
                {
                    ToolTip = 'แสดงผลซอย (SoiName) ด้วยค่าใน Field นี้';
                }
                field("Street Display"; Rec."Street Display")
                {
                    ToolTip = 'แสดงผลถนน (StreetName) ด้วยค่าใน Field นี้';
                }
                field("Thambon Display"; Rec."Thambon Display")
                {
                    ToolTip = 'แสดงผลตำบล (ThumbolName) ด้วยค่าใน Field นี้ หากเป็นกรุงเทพมหานคร จะแสดงเป็นแขวงโดยอัตโนมัติ';
                }
                field("Amphur Display"; Rec."Amphur Display")
                {
                    ToolTip = 'แสดงผลอำเภอ (AmphurName) ด้วยค่าใน Field นี้ หากเป็นกรุงเทพมหานคร จะแสดงเป็นเขตโดยอัตโนมัติ';
                }
                field("Province Display"; Rec."Province Display")
                {
                    ToolTip = 'แสดงผลจังหวัด (ProvinceName) ด้วยค่าใน Field นี้';
                }
                field("Exclude Province Display"; Rec."Exclude Province Display")
                {
                    ToolTip = 'ระบุจังหวัดที่ไม่ต้องการให้แสดงคำนำหน้าชื่อ (เช่น กรุงเทพมหานคร ใส่ , คั่นระหว่างจังหวัด)';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Initialize")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Setup;
                Caption = 'Initialize';
                ToolTip = 'Initialize with default values';
                AboutText = 'หากตัวอักษรยาวไปเช่น ถนน สามารถลดให้สั้นลงได้ เช่น ถ. โดยแก้ไขแบบ Manual';

                trigger OnAction()
                begin
                    Rec."Moo Display" := 'หมู่ที่ ';
                    Rec."Soi Display" := 'ซอย ';
                    Rec."Street Display" := 'ถนน ';
                    Rec."Thambon Display" := 'ตำบล ';
                    Rec."Amphur Display" := 'อำเภอ ';
                    Rec."Province Display" := 'จังหวัด ';
                    Rec."Exclude Province Display" := '';
                    Rec.Modify();
                    Message('Initialized with default values.');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

}