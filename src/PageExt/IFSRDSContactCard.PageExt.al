pageextension 80200 "IFS RDS Contact Card" extends "Contact Card"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("Apply Template")
        {
            action("GetDataRDVATService")
            {
                ApplicationArea = All;
                Caption = 'Get Data from RD VAT Service';
                ToolTip = 'Get Data from RD VAT Service';
                Image = GetSourceDoc;
                trigger OnAction()
                var
                    IFSRDVATService: Codeunit "IFS RD VAT Service";
                begin
#pragma warning disable AA0139
                    IFSRDVATService.ValidateContactDatafromRD(Rec."No.", Rec."VAT Registration No.", Rec.IFS_Branch_CRM);
#pragma warning restore AA0139
                end;
            }
        }
        addafter("Apply Template_Promoted")
        {
            actionref(GetDataRDVATServicePromote; GetDataRDVATService) { }
        }
    }

}