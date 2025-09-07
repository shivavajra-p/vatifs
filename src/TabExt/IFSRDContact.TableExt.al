
namespace IFS.RDVATService;

using Microsoft.CRM.Contact;

tableextension 80200 "IFS RD Contact" extends Contact
{
    fields
    {
        // Add changes to table fields here
        field(80200; "IFS RD Validate Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'RD Validate Date';
        }
        field(80201; "IFS RD Validate By"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'RD Validate By';
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

}