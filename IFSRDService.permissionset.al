namespace IFS.RDVATService;

permissionset 80200 IFSRDService
{
    Assignable = true;
    Permissions = tabledata "IFS RD Setup" = RIMD,
        table "IFS RD Setup" = X,
        codeunit "IFS RD VAT Service" = X,
        page "IFS RD Setup" = X;
}