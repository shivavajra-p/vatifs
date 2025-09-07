namespace IFS.RDVATService;
using Microsoft.Sales.Setup;
table 80200 "IFS RD Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            AllowInCustomizations = Never;
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }

        field(2; "Moo Display"; Text[20])
        {
            Caption = 'Moo Display';
            ToolTip = 'หมู่ที่ (MooNumber)';
            DataClassification = CustomerContent;
        }
        field(3; "Soi Display"; Text[20])
        {
            Caption = 'Soi Display';
            ToolTip = 'ซอย (SoiName)';
            DataClassification = CustomerContent;
        }
        field(4; "Street Display"; Text[20])
        {
            Caption = 'Street Display';
            ToolTip = 'ถนน (StreetName)';
            DataClassification = CustomerContent;
        }
        field(5; "Thambon Display"; Text[20])
        {
            Caption = 'Thambon Display';
            ToolTip = 'ตำบล (ThumbolName)';
            DataClassification = CustomerContent;
        }
        field(6; "Amphur Display"; Text[20])
        {
            Caption = 'Amphur Display';
            ToolTip = 'อำเภอ (AmphurName)';
            DataClassification = CustomerContent;
        }
        field(7; "Province Display"; Text[20])
        {
            Caption = 'Province Display';
            ToolTip = 'จังหวัด (ProvinceName)';
            DataClassification = CustomerContent;
        }
        field(8; "Exclude Province Display"; Text[250])
        {
            Caption = 'Exclude Province Display';
            ToolTip = 'จังหวัดที่ไม่ต้องการให้แสดงคำนำหน้าชื่อ (เช่น กรุงเทพมหานคร ใส่ , คั่นระหว่างจังหวัด)';
            DataClassification = CustomerContent;
        }
        field(9; "Notify after update"; Boolean)
        {
            Caption = 'Notify after update';
            ToolTip = 'แจ้งเตือนหลังจากมีการอัพเดทข้อมูลจาก RD VAT Service';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}