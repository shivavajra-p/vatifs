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
                field("Notify after update"; Rec."Notify after update")
                {
                    ToolTip = 'หากเลือกค่าใน Field นี้ จะมีการแจ้งเตือนหลังจากมีการอัพเดทข้อมูลจาก RD VAT Service';
                }
            }
            group(Info)
            {
                field(infoInstruction; this.infoInstruction)
                {
                    ShowCaption = false;
                    MultiLine = true;
                    ToolTip = 'Instructions for using the IFS RD VAT Service.';
                    Caption = 'Instructions';
                    Editable = true;
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
        // ชื่ออาคาร (BuildingName)
        // ห้องที่ (RoomNumber)
        // ชั้นที่ (FloorNumber)
        // หมู่บ้าน (VillageName)
        // เลขที่ตั้งของสถานประกอบการ (HouseNumber)
        // หมู่ที่ (MooNumber)
        // ซอย (SoiName)
        // ถนน (StreetName)
        this.infoInstruction :=
            @'Instructions for using the IFS RD VAT Service.
            1. Address 1 = BuildingName + RoomNumber + FloorNumber + VillageName + HouseNumber + MooNumber + SoiName + StreetName
            2. Address 2 = ThambonName
            3. City = AmphurName
            4. Province = ProvinceName
            5. Postcode = PostalCode
            Exclude Province from prefix name (e.g., Bangkok, separate by comma)
            
            คำแนะนำการใช้งาน IFS RD VAT Service
            1. ที่อยู่ 1 = ชื่ออาคาร + หมายเลขห้อง + หมายเลขชั้น + ชื่อหมู่บ้าน + หมายเลขที่ตั้ง + หมู่ที่ + ซอย + ถนน
            2. ที่อยู่ 2 = ชื่อตำบล
            3. เมือง = ชื่ออำเภอ
            4. จังหวัด = ชื่อจังหวัด
            5. รหัสไปรษณีย์ = รหัสไปรษณีย์
            6. จังหวัดที่ไม่ต้องการให้แสดงคำนำหน้าชื่อ (เช่น กรุงเทพมหานคร ใส่ , คั่นระหว่างจังหวัด)'
            ;
    end;

    var
        infoInstruction: Text;
}