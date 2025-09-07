namespace IFS.RDVATService;
using Microsoft.CRM.Contact;
using Microsoft.Sales.History;
pageextension 80200 "IFS RDS Contact Card" extends "Contact Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
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
                    Contact: Record Contact;
                    IFSRDVATService: Codeunit "IFS RD VAT Service";
                begin
                    Contact.Reset();
                    Contact.setrange("No.", Rec."No.");
                    Contact.FindFirst();
                    IFSRDVATService.ValidateContactDatafromRD(Contact);
                end;
            }


            action("IFS RD Setup")
            {
                ApplicationArea = All;
                Caption = 'IFS RD Setup';
                ToolTip = 'Open IFS RD Setup';
                AboutText = 'Open IFS RD Setup';
                AboutTitle = 'Open IFS RD Setup';
                Image = Setup;
                trigger OnAction()
                var
                    IFSRDSetupPage: Page "IFS RD Setup";
                begin
                    IFSRDSetupPage.Run();
                end;
            }
        }
        addafter("Apply Template_Promoted")
        {
            group("RDVATServicePromoted")
            {
                Caption = 'RD VAT Service';
                AboutText = 'Actions related to RD VAT Service.';
                AboutTitle = 'RD VAT Service';
                actionref(GetDataRDVATServicePromote; GetDataRDVATService) { }
                actionref(IFS_RD_Setup_Promote; "IFS RD Setup") { }

            }
        }
    }
    var
        X: page "Posted Sales Invoice";
}