namespace IFS.RDVATService;
page 80200 TestPage
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            group(VATIDGroup)
            {
                field(VATID; this.VATID)
                {
                    ApplicationArea = All;
                    Caption = 'VAT ID';
                    ToolTip = 'Enter the VAT ID to validate.';
                }
                field(BranchNo; this.BranchNo)
                {
                    ApplicationArea = All;
                    Caption = 'Branch No';
                    ToolTip = 'Enter the Branch No to validate.';
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(GetData)
            {
                ToolTip = 'Get Data from RD VAT Service';
                trigger OnAction()
                var
                    CUD: Codeunit "IFS RD VAT Service";
                begin
                    //CUD.SetVATID(this.VATID, this.BranchNo);
                    CUD.Run()
                end;
            }
        }
    }

    var
        VATID: Code[13];
        BranchNo: Integer;
}
