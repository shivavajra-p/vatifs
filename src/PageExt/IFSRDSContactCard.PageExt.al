namespace IFS.RDVATService;
using Microsoft.CRM.Contact;
pageextension 80200 "IFS RDS Contact Card" extends "Contact Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(Communication)
        {
            group("RD VAT Service")
            {
                AboutText = 'RD VAT Service';
                AboutTitle = 'RD VAT Service';
                InstructionalText = 'This group contains fields related to the RD VAT Service.';
                Caption = 'RD VAT Service';
                field("RD Validate Date"; Rec."IFS RD Validate Date")
                {
                    ToolTip = 'Date of last validation from RD VAT Service';
                    ApplicationArea = All;
                    Editable = false;
                    AboutText = 'RD Validate Date';

                }
                field("RD Validate By"; Rec."IFS RD Validate By")
                {
                    ToolTip = 'User who last validated the data';
                    ApplicationArea = All;
                    Editable = false;
                    AboutText = 'RD Validate By';
                    InstructionalText = 'This field shows the user who last validated the data from the RD VAT Service.';
                }
            }
        }
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
                AboutText = 'Get Data from RD VAT Service';
                AboutTitle = 'Get Data from RD VAT Service';
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