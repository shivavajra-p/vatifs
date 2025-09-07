/// <summary>
/// Thai Revenue Department VAT Validation Service
/// 
/// This codeunit provides comprehensive VAT validation functionality by connecting to the 
/// Thai Revenue Department's web service. It validates VAT IDs (Tax Identification Numbers)
/// and retrieves complete company information including address details.
/// 
/// Key Features:
/// - SOAP 1.1 protocol communication with RD web service
/// - Comprehensive data extraction (23+ fields)
/// - Robust XML parsing with multiple fallback strategies
/// - Helper functions for easy data access
/// - Built-in error handling and validation
/// - Debug infrastructure for troubleshooting
/// 
/// Usage:
/// 1. Call SetVATID() to set VAT ID and branch number
/// 2. Use CheckVatOnce() to validate and get company data
/// 3. Extract specific data using helper functions (GetCompanyName, GetProvince, etc.)
/// 
/// Author: [Your Name]
/// Created: August 2025
/// Version: 2.0
/// </summary>

namespace IFS.RDVATService;

using System.Reflection;
using Microsoft.CRM.Contact;
codeunit 80200 "IFS RD VAT Service"
{
    SingleInstance = false;

    /// <summary>
    /// Main entry point - automatically called when codeunit is run
    /// Uses the global VAT ID and branch number to fetch data from RD web service
    /// </summary>
    trigger OnRun()
    begin
        //this.GetDatafromRDweb(this.GlobalVATID, this.GlobalBranchNo);
    end;

    /// <summary>
    /// Sets the VAT ID and branch number for validation
    /// 
    /// Validates that the VAT ID is exactly 13 numeric characters and stores both
    /// the VAT ID and branch number in global variables for later use.
    /// </summary>
    /// <param name="VATID">The 13-digit VAT identification number to validate</param>
    /// <param name="BranchNo">The branch number (0 for head office, >0 for branches)</param>
    /// <exception cref="Error">Thrown when VAT ID length is not 13 characters</exception>
    /// <exception cref="Error">Thrown when VAT ID contains non-numeric characters</exception>
    local procedure SetVATID(VATID: Code[13]; BranchCode: Code[20])
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        this.GlobalVATID := VATID;


        // Validate VAT ID length - Thai VAT IDs must be exactly 13 digits
        if StrLen(this.GlobalVATID) <> 13 then
            Error('Invalid VAT ID length. VAT ID must be 13 characters long.');

        // Validate VAT ID format - must contain only numeric characters (0-9)
        if not TypeHelper.IsNumeric(this.GlobalVATID) then
            Error('Invalid VAT ID. VAT ID must contain only numeric characters.');

        this.GlobalBranchNo := this.ValidateBranchCode(BranchCode);
    end;

    local procedure ValidateBranchCode(BranchCode: Code[20]): Integer
    var
        TypeHelper: Codeunit "Type Helper";
        BranchNo: Integer;
    begin
        if BranchCode = '' then
            Error('Branch No cannot be empty.');
        if BranchCode = 'สำนักงานใหญ่' then
            BranchNo := 0
        else begin
            // BranchCode must be numeric 5 digits
            if StrLen(BranchCode) <> 5 then
                Error('Branch No must be numeric 5 digits.');
            if not TypeHelper.IsNumeric(BranchCode) then
                Error('Branch No must be numeric 5 digits.');
            // Convert to integer
            Evaluate(BranchNo, BranchCode);
        end;
        exit(BranchNo);
    end;

    /// <summary>
    /// Internal test method that fetches and displays VAT data from RD web service
    /// 
    /// This method is primarily used for testing and demonstration purposes.
    /// It calls the VAT validation service and displays the results in a message box.
    /// In production, you would typically call CheckVatOnce directly and handle
    /// the JSON response according to your business needs.
    /// </summary>
    /// <param name="VATIDv">The 13-digit VAT ID to validate</param>
    /// <param name="BranchNov">The branch number to query</param>
    local procedure GetDatafromRDweb(VATIDv: Code[13]; BranchNov: Integer)
    var
        ErrorMsg: Text;

    begin
        // Basic validation - ensure VAT ID is not empty
        if VATIDv = '' then
            Error('Invalid VAT ID. VAT ID must be 13 characters long.');

        // Call the main validation service with anonymous credentials
        // Note: Replace 'anonymous' with actual RD service credentials in production
        if this.CheckVatOnce(VATIDv, BranchNov, 'anonymous', 'anonymous', this.GlobalJo) then begin
            this.GlobalSuccess := this.IsSuccess(this.GlobalJo);
            if not this.GlobalSuccess then
                Error('Error: %1', ErrorMsg);
        end else
            // Network or service connection failure
            Message('Failed to connect to VAT service');

    end;

    /// <summary>
    /// Internal test method that fetches and displays VAT data from RD web service
    /// 
    /// This method is primarily used for testing and demonstration purposes.
    /// It calls the VAT validation service and displays the results in a message box.
    /// In production, you would typically call CheckVatOnce directly and handle
    /// the JSON response according to your business needs.
    /// </summary>
    /// <param name="VATIDv">The 13-digit VAT ID to validate</param>
    /// <param name="BranchNov">The branch number to query</param>
#pragma warning disable AA0228
    local procedure GetDatafromRDwebTesting(VATIDv: Code[13]; BranchNov: Integer)
#pragma warning restore AA0228
    var
        LocalJo: JsonObject;
        LocalCompanyName: Text;
        LocalAddress: Text;
        LocalSuccess: Boolean;
        LocalVatId: Text;
        LocalProvince: Text;
        LocalPostCode: Text;
        LocalBranchNumber: Text;
        ErrorMsg: Text;
    begin
        // Basic validation - ensure VAT ID is not empty
        if VATIDv = '' then
            Error('Invalid VAT ID. VAT ID must be 13 characters long.');

        // Call the main validation service with anonymous credentials
        // Note: Replace 'anonymous' with actual RD service credentials in production
        if this.CheckVatOnce(VATIDv, BranchNov, 'anonymous', 'anonymous', LocalJo) then begin
            LocalSuccess := this.IsSuccess(LocalJo);
            if LocalSuccess then begin
                // Extract individual data fields for display
                LocalVatId := this.GetVatId(LocalJo);
                LocalCompanyName := this.GetCompanyName(LocalJo);
                LocalProvince := this.GetProvince(LocalJo);
                LocalPostCode := this.GetPostCode(LocalJo);
                LocalBranchNumber := this.GetBranchNumber(LocalJo);
                LocalAddress := this.GetFullAddressTest(LocalJo);
                ErrorMsg := this.GetErrorMessage(LocalJo); //ถ้ามี แปลว่า Error

                // Display comprehensive validation results
                Message('VAT Lookup Success!\n' +
                       'VAT ID: %1\n' +
                       'Company: %2\n' +
                       'Province: %3\n' +
                       'Post Code: %4\n' +
                       'Branch: %5\n' +
                       'Full Address: %6\n' +
                       'Error Message: %7',
                       LocalVatId, LocalCompanyName, LocalProvince, LocalPostCode, LocalBranchNumber, LocalAddress, ErrorMsg);
            end else
                // Display error message from RD service
                Message('Error: %1', ErrorMsg);
        end else
            // Network or service connection failure
            Message('Failed to connect to VAT service');

    end;

    /// <summary>
    /// Main VAT validation method - connects to Thai RD web service
    /// 
    /// This is the core method that performs SOAP communication with the Thai Revenue 
    /// Department's VAT validation service. It builds a SOAP envelope, sends the request,
    /// and parses the XML response into a structured JSON object for easy data access.
    /// 
    /// The method uses SOAP 1.1 protocol which is preferred by the RD service.
    /// </summary>
    /// <param name="TIN">Tax Identification Number (13 digits)</param>
    /// <param name="BranchNo">Branch number (0 = head office, >0 = branch)</param>
    /// <param name="Username">RD service username (use 'anonymous' for public access)</param>
    /// <param name="Password">RD service password (use 'anonymous' for public access)</param>
    /// <param name="ResultJson">Output parameter containing structured response data</param>
    /// <returns>True if request was successful, False if network/service error occurred</returns>
    procedure CheckVatOnce(TIN: Code[13]; BranchNo: Integer; Username: Text; Password: Text; var ResultJson: JsonObject): Boolean
    var
        Url: Text;
        SoapXml: Text;
        Client: HttpClient;
        Content: HttpContent;
        Resp: HttpResponseMessage;
        Headers: HttpHeaders;
        RespText: Text;
    begin
        Clear(ResultJson);
        Url := 'https://rdws.rd.go.th/serviceRD3/vatserviceRD3.asmx';

        // Step 1: Build SOAP 1.1 envelope with validation parameters
        SoapXml := this.BuildSoapEnvelope(Username, Password, TIN, BranchNo);

        // Step 2: Prepare HTTP content with SOAP 1.1 headers
        // Content-Type must be 'text/xml' for SOAP 1.1 (not 'application/soap+xml')
        Content.WriteFrom(SoapXml);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml; charset=utf-8');
        Headers.Add('SOAPAction', 'https://rdws.rd.go.th/serviceRD3/vatserviceRD3/Service');

        // Step 3: Send HTTP POST request to RD service
        if not Client.Post(Url, Content, Resp) then
            exit(false);

        // Step 4: Handle HTTP response and error cases
        if not Resp.IsSuccessStatusCode() then begin
            Resp.Content().ReadAs(RespText);
            // Store error information in JSON for caller to handle
            ResultJson.Add('success', false);
            ResultJson.Add('httpStatus', Resp.HttpStatusCode());
            ResultJson.Add('raw', RespText);
            exit(false);
        end;

        Resp.Content().ReadAs(RespText);

        // Step 5: Parse XML response and convert to structured JSON
        exit(this.ParseResponseToJson(RespText, ResultJson));
    end;

    /// <summary>
    /// Builds SOAP 1.1 envelope for RD VAT service request
    /// 
    /// Creates a properly formatted SOAP envelope that conforms to the Thai Revenue
    /// Department's web service specification. The envelope includes all required
    /// parameters and uses the correct namespaces.
    /// 
    /// Note: SOAP 1.1 format is used instead of 1.2 as it's preferred by the RD service.
    /// </summary>
    /// <param name="Username">Service username (typically 'anonymous')</param>
    /// <param name="Password">Service password (typically 'anonymous')</param>
    /// <param name="TIN">Tax Identification Number to validate</param>
    /// <param name="BranchNo">Branch number to query</param>
    /// <returns>Complete SOAP XML envelope ready for transmission</returns>
    local procedure BuildSoapEnvelope(Username: Text; Password: Text; TIN: Code[13]; BranchNo: Integer): Text
    var
        Soap: TextBuilder;
    begin
        // Build SOAP 1.1 envelope with proper namespaces
        // Using SOAP 1.1 format as Thai RD service expects this version
        Soap.AppendLine('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"');
        Soap.AppendLine('                xmlns:vat="https://rdws.rd.go.th/serviceRD3/vatserviceRD3">');
        Soap.AppendLine('  <soap:Header/>');
        Soap.AppendLine('  <soap:Body>');
        Soap.AppendLine('    <vat:Service>');
        Soap.AppendLine('      <vat:username>' + this.XmlEncode(Username) + '</vat:username>');
        Soap.AppendLine('      <vat:password>' + this.XmlEncode(Password) + '</vat:password>');
        Soap.AppendLine('      <vat:TIN>' + Format(TIN) + '</vat:TIN>');
        Soap.AppendLine('      <vat:Name></vat:Name>');                    // Empty - search by TIN only
        Soap.AppendLine('      <vat:ProvinceCode>0</vat:ProvinceCode>');   // 0 = all provinces
        Soap.AppendLine('      <vat:BranchNumber>' + Format(BranchNo) + '</vat:BranchNumber>');
        Soap.AppendLine('      <vat:AmphurCode>0</vat:AmphurCode>');       // 0 = all districts
        Soap.AppendLine('    </vat:Service>');
        Soap.AppendLine('  </soap:Body>');
        Soap.AppendLine('</soap:Envelope>');
        exit(Soap.ToText());
    end;

    /// <summary>
    /// Parses XML response from RD service into structured JSON format
    /// 
    /// This method handles the complex XML response from the Thai Revenue Department
    /// and converts it into an easy-to-use JSON object. It implements multiple
    /// parsing strategies to handle namespace issues and ensures robust data extraction.
    /// 
    /// The method extracts all 23+ data fields returned by the service including:
    /// - Company identification (VAT ID, name, title)
    /// - Address components (house, village, street, district, province, postal code)
    /// - Branch information and business registration details
    /// 
    /// Includes comprehensive debug infrastructure that can be activated by
    /// uncommenting debug lines for troubleshooting XML parsing issues.
    /// </summary>
    /// <param name="ResponseXml">Raw XML response from RD web service</param>
    /// <param name="ResultJson">Output JSON object with structured data</param>
    /// <returns>True if parsing successful, False if XML is invalid or ServiceResult not found</returns>
    local procedure ParseResponseToJson(ResponseXml: Text; var ResultJson: JsonObject): Boolean
    var
        XmlDoc: XmlDocument;
        ServiceResultNode: XmlNode;
    begin
        if not XmlDocument.ReadFrom(ResponseXml, XmlDoc) then begin
            ResultJson.Add('success', false);
            ResultJson.Add('error', 'Invalid XML response');
            ResultJson.Add('raw', ResponseXml);
            exit(false);
        end;


        // Try to find ServiceResult without namespace complications - multiple approaches
#pragma warning disable AA0005
        if XmlDoc.SelectSingleNode('//ServiceResult', ServiceResultNode) then begin
            // Message('Found ServiceResult node successfully!'); // Debug: Uncomment for troubleshooting
        end else
#pragma warning disable AA0018
            if XmlDoc.SelectSingleNode('//*[local-name()="ServiceResult"]', ServiceResultNode) then begin
#pragma warning restore AA0018
                // Message('Found ServiceResult using local-name!'); // Debug: Uncomment for troubleshooting
            end else begin
                // Message('ServiceResult not found, trying to find any result structure...'); // Debug: Uncomment for troubleshooting
                // Try to find the response body and show its structure
                // if XmlDoc.SelectSingleNode('//Body', ServiceResultNode) then begin
                //     Message('Found SOAP Body: %1', CopyStr(GetInnerXml(ServiceResultNode), 1, 800)); // Debug: Uncomment for troubleshooting
                // end else begin
                //     Message('No SOAP Body found. Full XML:\n%1', CopyStr(ResponseXml, 1, 1000)); // Debug: Uncomment for troubleshooting
                // end;

                ResultJson.Add('success', false);
                ResultJson.Add('error', 'ServiceResult not found');
                ResultJson.Add('raw', ResponseXml);
                exit(false);
            end;
#pragma warning restore AA0018

        // Message('ServiceResult content: %1', CopyStr(GetInnerXml(ServiceResultNode), 1, 800)); // Debug: Uncomment for troubleshooting

        // Debug: List all child elements
        // ShowAllChildElements(ServiceResultNode); // Debug: Uncomment for troubleshooting

        // Extract data using simple approach - no namespace complications
        ResultJson.Add('vNID', this.GetSimpleChildText(ServiceResultNode, 'vNID'));                 // National ID / เลขบัตรประชาชน
        ResultJson.Add('vtin', this.GetSimpleChildText(ServiceResultNode, 'vtin'));                 // Tax Identification Number / เลขประจำตัวผู้เสียภาษี
        ResultJson.Add('vtitleName', this.GetSimpleChildText(ServiceResultNode, 'vtitleName'));           // Title Name / คำนำหน้าชื่อ
        ResultJson.Add('vName', this.GetSimpleChildText(ServiceResultNode, 'vName'));                // Company/Person Name / ชื่อบริษัท/บุคคล
        ResultJson.Add('vSurname', this.GetSimpleChildText(ServiceResultNode, 'vSurname'));             // Surname / นามสกุล
        ResultJson.Add('vBranchTitleName', this.GetSimpleChildText(ServiceResultNode, 'vBranchTitleName'));     // Branch Title Name / คำนำหน้าชื่อสาขา
        ResultJson.Add('vBranchName', this.GetSimpleChildText(ServiceResultNode, 'vBranchName'));          // Branch Name / ชื่อสาขา
        ResultJson.Add('vBranchNumber', this.GetSimpleChildText(ServiceResultNode, 'vBranchNumber'));        // Branch Number / เลขที่สาขา
        ResultJson.Add('vBuildingName', this.GetSimpleChildText(ServiceResultNode, 'vBuildingName'));        // Building Name / ชื่ออาคาร
        ResultJson.Add('vFloorNumber', this.GetSimpleChildText(ServiceResultNode, 'vFloorNumber'));         // Floor Number / เลขที่ชั้น
        ResultJson.Add('vVillageName', this.GetSimpleChildText(ServiceResultNode, 'vVillageName'));         // Village Name / ชื่อหมู่บ้าน
        ResultJson.Add('vRoomNumber', this.GetSimpleChildText(ServiceResultNode, 'vRoomNumber'));          // Room Number / เลขที่ห้อง
        ResultJson.Add('vHouseNumber', this.GetSimpleChildText(ServiceResultNode, 'vHouseNumber'));         // House Number / เลขที่บ้าน
        ResultJson.Add('vMooNumber', this.GetSimpleChildText(ServiceResultNode, 'vMooNumber'));           // Moo Number (Village Group) / หมู่ที่
        ResultJson.Add('vSoiName', this.GetSimpleChildText(ServiceResultNode, 'vSoiName'));             // Soi Name (Alley) / ชื่อซอย
        ResultJson.Add('vStreetName', this.GetSimpleChildText(ServiceResultNode, 'vStreetName'));          // Street Name / ชื่อถนน
        ResultJson.Add('vThambol', this.GetSimpleChildText(ServiceResultNode, 'vThambol'));             // Sub-district (Tambon) / ตำบล
        ResultJson.Add('vAmphur', this.GetSimpleChildText(ServiceResultNode, 'vAmphur'));              // District (Amphoe) / อำเภอ
        ResultJson.Add('vProvince', this.GetSimpleChildText(ServiceResultNode, 'vProvince'));            // Province / จังหวัด
        ResultJson.Add('vPostCode', this.GetSimpleChildText(ServiceResultNode, 'vPostCode'));            // Postal Code / รหัสไปรษณีย์
        ResultJson.Add('vBusinessFirstDate', this.GetSimpleChildText(ServiceResultNode, 'vBusinessFirstDate'));   // Business Registration Date / วันที่จดทะเบียนธุรกิจ
        ResultJson.Add('vYaek', this.GetSimpleChildText(ServiceResultNode, 'vYaek'));                // Junction/Intersection / แยก
        ResultJson.Add('vmsgerr', this.GetSimpleChildText(ServiceResultNode, 'vmsgerr'));              // Error Message / ข้อความแสดงข้อผิดพลาด

        // Test message to verify data extraction
        // Message('Data Extraction Test:\nvNID: %1\nvName: %2\nvProvince: %3\nvmsgerr: %4', // Debug: Uncomment for troubleshooting
        //         GetSimpleChildText(ServiceResultNode, 'vNID'),
        //         GetSimpleChildText(ServiceResultNode, 'vName'),
        //         GetSimpleChildText(ServiceResultNode, 'vProvince'),
        //         GetSimpleChildText(ServiceResultNode, 'vmsgerr'));

        // สถานะรวม + raw
        ResultJson.Add('success', true);
        ResultJson.Add('raw', ResponseXml);

        exit(true);
    end;

    // ====================================================================
    // HELPER FUNCTIONS FOR DATA EXTRACTION
    // ====================================================================
    // These functions provide easy access to specific data fields from the
    // JSON response. Each function extracts one piece of information and
    // returns it as a Text value. This modular approach makes it easy to
    // get exactly the data you need without parsing the JSON manually.
    // ====================================================================

    /// <summary>
    /// Gets the National ID / VAT registration number from validation result
    /// ฟังก์ชันสำหรับดึงเลขบัตรประชาชน/เลขทะเบียนภาษี
    /// </summary>
    /// <param name="ResultJson">JSON response from VAT validation service</param>
    /// <returns>National ID number or empty string if not found</returns>
    procedure GetVatId(ResultJson: JsonObject): Text
    begin
        exit(this.GetJsonValue(ResultJson, 'vNID'));
    end;

    /// <summary>
    /// Gets the Tax Identification Number (TIN) from validation result
    /// ฟังก์ชันสำหรับดึงเลขประจำตัวผู้เสียภาษี
    /// </summary>
    procedure GetVatTin(ResultJson: JsonObject): Text
    begin
        exit(this.GetJsonValue(ResultJson, 'vtin'));
    end;

    /// <summary>
    /// Gets the company/person title name (นาย, นาง, นางสาว, บริษัท, etc.)
    /// ฟังก์ชันสำหรับดึงคำนำหน้าชื่อ
    /// </summary>
    procedure GetCompanyTitleName(ResultJson: JsonObject): Text
    begin
        if this.GetJsonValue(ResultJson, 'vtitleName') = '-' then
            exit('')
        else
            exit(this.GetJsonValue(ResultJson, 'vtitleName'));
    end;

    /// <summary>
    /// Gets the company or person name
    /// ฟังก์ชันสำหรับดึงชื่อบริษัทหรือบุคคล
    /// </summary>
    procedure GetCompanyName(ResultJson: JsonObject): Text
    begin
        if this.GetJsonValue(ResultJson, 'vName') = '-' then
            exit('')
        else
            exit(this.GetJsonValue(ResultJson, 'vName'));
    end;

    /// <summary>
    /// Gets the surname (for individual taxpayers)
    /// ฟังก์ชันสำหรับดึงนามสกุล (สำหรับบุคคลธรรมดา)
    /// </summary>
    procedure GetCompanySurname(ResultJson: JsonObject): Text
    begin
        if this.GetJsonValue(ResultJson, 'vSurname') = '-' then
            exit('')
        else
            exit(this.GetJsonValue(ResultJson, 'vSurname'));
    end;

    /// <summary>
    /// Gets the branch title name
    /// ฟังก์ชันสำหรับดึงคำนำหน้าชื่อสาขา
    /// </summary>
    procedure GetBranchTitleName(ResultJson: JsonObject): Text
    begin
        if this.GetJsonValue(ResultJson, 'vBranchTitleName') = '-' then
            exit('')
        else
            exit(this.GetJsonValue(ResultJson, 'vBranchTitleName'));
    end;

    /// <summary>
    /// Gets the branch name
    /// ฟังก์ชันสำหรับดึงชื่อสาขา
    /// </summary>
    procedure GetBranchName(ResultJson: JsonObject): Text
    begin
        if this.GetJsonValue(ResultJson, 'vBranchName') = '-' then
            exit('')
        else
            exit(this.GetJsonValue(ResultJson, 'vBranchName'));
    end;

    /// <summary>
    /// Gets the branch number (0 = head office, >0 = branch)
    /// ฟังก์ชันสำหรับดึงเลขที่สาขา (0 = สำนักงานใหญ่, >0 = สาขา)
    /// </summary>
    procedure GetBranchNumber(ResultJson: JsonObject): Text
    begin
        if this.GetJsonValue(ResultJson, 'vBranchNumber') = '-' then
            exit('')
        else
            exit(this.GetJsonValue(ResultJson, 'vBranchNumber'));
    end;

    // ====================================================================
    // ADDRESS COMPONENT FUNCTIONS
    // ====================================================================
    // These functions extract individual address components that can be
    // combined to form a complete Thai address format
    // ====================================================================

    /// <summary>
    /// Gets the building name
    /// ฟังก์ชันสำหรับดึงชื่ออาคาร
    /// </summary>
    procedure GetBuildingName(ResultJson: JsonObject): Text
    var
        BuildingName: Text;
    begin
        BuildingName := this.GetJsonValue(ResultJson, 'vBuildingName');
        BuildingName := BuildingName.Trim();
        if BuildingName = '-' then
            exit('')
        else
            exit(BuildingName);
    end;

    /// <summary>
    /// Gets the floor number
    /// ฟังก์ชันสำหรับดึงเลขที่ชั้น
    /// </summary>
    procedure GetFloorNumber(ResultJson: JsonObject): Text
    var
        FloorNumber: Text;
    begin
        FloorNumber := this.GetJsonValue(ResultJson, 'vFloorNumber');
        FloorNumber := FloorNumber.Trim();
        if FloorNumber = '-' then
            exit('')
        else
            exit(FloorNumber);
    end;

    /// <summary>
    /// Gets the village name
    /// ฟังก์ชันสำหรับดึงชื่อหมู่บ้าน
    /// </summary>
    procedure GetVillageName(ResultJson: JsonObject): Text
    var
        VillageName: Text;
    begin
        VillageName := this.GetJsonValue(ResultJson, 'vVillageName');
        VillageName := VillageName.Trim();
        if VillageName = '-' then
            exit('')
        else
            exit(VillageName);
    end;

    /// <summary>
    /// Gets the room number
    /// ฟังก์ชันสำหรับดึงเลขที่ห้อง
    /// </summary>
    procedure GetRoomNumber(ResultJson: JsonObject): Text
    var
        RoomNumber: Text;
    begin
        RoomNumber := this.GetJsonValue(ResultJson, 'vRoomNumber');
        RoomNumber := RoomNumber.Trim();
        if (RoomNumber = '-') or (RoomNumber = '-.') then
            exit('')
        else
            exit(RoomNumber);
    end;

    /// <summary>
    /// Gets the house number
    /// ฟังก์ชันสำหรับดึงเลขที่บ้าน
    /// </summary>
    procedure GetHouseNumber(ResultJson: JsonObject): Text
    var
        HouseNumber: Text;
    begin
        HouseNumber := this.GetJsonValue(ResultJson, 'vHouseNumber');
        HouseNumber := HouseNumber.Trim();
        if HouseNumber = '-' then
            exit('')
        else
            exit(HouseNumber);
    end;

    /// <summary>
    /// Gets the Moo (village group) number
    /// ฟังก์ชันสำหรับดึงหมู่ที่
    /// </summary>
    procedure GetMooNumber(ResultJson: JsonObject): Text
    var
        MooNumber: Text;
    begin
        MooNumber := this.GetJsonValue(ResultJson, 'vMooNumber');
        MooNumber := MooNumber.Trim();
        if MooNumber = '-' then
            exit('')
        else
            exit(MooNumber);
    end;

    /// <summary>
    /// Gets the Soi (alley/lane) name
    /// ฟังก์ชันสำหรับดึงชื่อซอย
    /// </summary>
    procedure GetSoiName(ResultJson: JsonObject): Text
    var
        SoiName: Text;
    begin
        SoiName := this.GetJsonValue(ResultJson, 'vSoiName');
        SoiName := SoiName.Trim();
        if SoiName = '-' then
            exit('')
        else
            exit(SoiName);
    end;

    /// <summary>
    /// Gets the street name
    /// ฟังก์ชันสำหรับดึงชื่อถนน
    /// </summary>
    procedure GetStreetName(ResultJson: JsonObject): Text
    var
        StreetName: Text;
    begin
        StreetName := this.GetJsonValue(ResultJson, 'vStreetName');
        StreetName := StreetName.Trim();
        if StreetName = '-' then
            exit('')
        else
            exit(StreetName);
    end;

    /// <summary>
    /// Gets the Tambon (sub-district) name
    /// ฟังก์ชันสำหรับดึงชื่อตำบล
    /// </summary>
    procedure GetThambol(ResultJson: JsonObject): Text
    var
        Thambol: Text;
    begin
        Thambol := this.GetJsonValue(ResultJson, 'vThambol');
        Thambol := Thambol.Trim();
        if Thambol = '-' then
            exit('')
        else
            exit(Thambol);
    end;

    /// <summary>
    /// Gets the Amphoe (district) name
    /// ฟังก์ชันสำหรับดึงชื่ออำเภอ
    /// </summary>
    procedure GetAmphur(ResultJson: JsonObject): Text
    var
        Amphur: Text;
    begin
        Amphur := this.GetJsonValue(ResultJson, 'vAmphur');
        Amphur := Amphur.Trim();
        if Amphur = '-' then
            exit('')
        else
            exit(Amphur);
    end;

    /// <summary>
    /// Gets the province name
    /// ฟังก์ชันสำหรับดึงชื่อจังหวัด
    /// </summary>
    procedure GetProvince(ResultJson: JsonObject): Text
    var
        Province: Text;
    begin
        Province := this.GetJsonValue(ResultJson, 'vProvince');
        Province := Province.Trim();
        if Province = '-' then
            exit('')
        else
            exit(Province);
    end;

    /// <summary>
    /// Gets the postal code
    /// ฟังก์ชันสำหรับดึงรหัสไปรษณีย์
    /// </summary>
    procedure GetPostCode(ResultJson: JsonObject): Text
    var
        PostCode: Text;
    begin
        PostCode := this.GetJsonValue(ResultJson, 'vPostCode');
        PostCode := PostCode.Trim();
        if PostCode = '-' then
            exit('')
        else
            exit(PostCode);
    end;

    /// <summary>
    /// Gets the business first registration date
    /// ฟังก์ชันสำหรับดึงวันที่จดทะเบียนธุรกิจครั้งแรก
    /// </summary>
    procedure GetBusinessFirstDate(ResultJson: JsonObject): Text
    begin
        exit(this.GetJsonValue(ResultJson, 'vBusinessFirstDate'));
    end;

    /// <summary>
    /// Gets the Yaek (junction/intersection) name
    /// ฟังก์ชันสำหรับดึงชื่อแยก
    /// </summary>
    procedure GetYaek(ResultJson: JsonObject): Text
    begin
        exit(this.GetJsonValue(ResultJson, 'vYaek'));
    end;

    /// <summary>
    /// Gets error message from RD service response
    /// ฟังก์ชันสำหรับดึงข้อความแสดงข้อผิดพลาด
    /// </summary>
    procedure GetErrorMessage(ResultJson: JsonObject): Text
    begin
        exit(this.GetJsonValue(ResultJson, 'vmsgerr'));
    end;

    /// <summary>
    /// Checks if the VAT validation was successful
    /// ฟังก์ชันสำหรับตรวจสอบว่าการตรวจสอบ VAT สำเร็จหรือไม่
    /// </summary>
    /// <param name="ResultJson">JSON response from validation service</param>
    /// <returns>True if validation was successful, False otherwise</returns>
    procedure IsSuccess(ResultJson: JsonObject): Boolean
    var
        Token: JsonToken;
    begin
        if ResultJson.Get('success', Token) then
            exit(Token.AsValue().AsBoolean())
        else
            exit(false);
    end;

    /// <summary>
    /// Builds a complete Thai address string from individual components
    /// 
    /// This function combines all address components into a properly formatted
    /// Thai address string following standard Thai address conventions.
    /// Only non-empty components are included in the final address.
    /// 
    /// Thai address format: [House] [Village] [Moo] [Soi] [Street] [Tambon] [Amphoe] [Province] [PostCode]
    /// ฟังก์ชันสำหรับสร้างที่อยู่แบบไทยที่สมบูรณ์จากส่วนประกอบต่างๆ
    /// </summary>
    /// <param name="ResultJson">JSON response containing address components</param>
    /// <returns>Complete formatted Thai address string</returns>
    procedure GetFullAddressTest(ResultJson: JsonObject): Text
    var
        Address: TextBuilder;
        Component: Text;
    begin
        // Build complete Thai address from individual components
        // Each component is checked for empty values before adding
        // Order used:
        //  Building Name           / ชื่ออาคาร
        //  Floor Number            / เลขที่ชั้น
        //  Room Number             / เลขที่ห้อง
        //  House Number            / เลขที่บ้าน
        //  Moo (Village Group)     / หมู่ที่
        //  Soi (Alley)             / ชื่อซอย
        //  Street Name             / ชื่อถนน
        //  Sub-district (Tambon)   / ตำบล,แขวง
        //  District (Amphoe)       / อำเภอ,เขต
        //  Province                / จังหวัด
        //  Postal Code             / รหัสไปรษณีย์

        Component := this.GetBuildingName(ResultJson);
        if Component <> '' then
            Address.Append(Component + ' ');
        Component := this.GetFloorNumber(ResultJson);
        if Component <> '' then
            Address.Append('ชั้น' + Component + ' ');
        Component := this.GetRoomNumber(ResultJson);
        if Component <> '' then
            Address.Append('ห้อง' + Component + ' ');
        Component := this.GetHouseNumber(ResultJson);
        if Component <> '' then
            Address.Append(Component + ' ');
        Component := this.GetMooNumber(ResultJson);
        if Component <> '' then
            Address.Append('หมู่ ' + Component + ' ');
        Component := this.GetSoiName(ResultJson);
        if Component <> '' then
            Address.Append('ซอย' + Component + ' ');

        Component := this.GetStreetName(ResultJson);
        if Component <> '' then
            Address.Append('ถนน' + Component + ' ');

        Component := this.GetThambol(ResultJson);
        if Component <> '' then
            Address.Append('ตำบล' + Component + ' ');
        Component := this.GetAmphur(ResultJson);
        if Component <> '' then
            Address.Append('อำเภอ' + Component + ' ');
        Component := this.GetProvince(ResultJson);
        if Component <> '' then
            Address.Append('จังหวัด' + Component + ' ');
        Component := this.GetPostCode(ResultJson);
        if Component <> '' then
            Address.Append(Component);


        exit(Address.ToText().Trim());
    end;

    /// <summary>
    /// Builds a complete Thai address string from individual components
    /// 
    /// This function combines all address components into a properly formatted
    /// Thai address string following standard Thai address conventions.
    /// Only non-empty components are included in the final address.
    /// 
    /// Thai address format: [House] [Village] [Moo] [Soi] [Street] [Tambon] [Amphoe] [Province] [PostCode]
    /// ฟังก์ชันสำหรับสร้างที่อยู่แบบไทยที่สมบูรณ์จากส่วนประกอบต่างๆ
    /// </summary>
    /// <param name="ResultJson">JSON response containing address components</param>
    /// <returns>Complete formatted Thai address string</returns>
    procedure GetFullAddress(ResultJson: JsonObject; var Address1: Text[100]; var Address2: Text[50]; var City: Text[30]; var Province: Text[30]; var PostCode: Code[20])
    var
        Address: TextBuilder;
        Component: Text;
        Subdistrict: Text;
        District: Text;
    begin
        // Build complete Thai address from individual components
        // Each component is checked for empty values before adding
        // Order used:
        //  Building Name           / ชื่ออาคาร
        //  Floor Number            / เลขที่ชั้น
        //  Room Number             / เลขที่ห้อง
        //  House Number            / เลขที่บ้าน
        //  Moo (Village Group)     / หมู่ที่
        //  Soi (Alley)             / ชื่อซอย
        //  Street Name             / ชื่อถนน
        //  Sub-district (Tambon)   / ตำบล,แขวง
        //  District (Amphoe)       / อำเภอ,เขต
        //  Province                / จังหวัด
        //  Postal Code             / รหัสไปรษณีย์

        Component := this.GetBuildingName(ResultJson);
        if Component <> '' then
            Address.Append(Component.Trim() + ' ');
        Component := this.GetFloorNumber(ResultJson);
        if Component <> '' then
            Address.Append('ชั้น ' + Component.Trim() + ' ');
        Component := this.GetRoomNumber(ResultJson);
        if Component <> '' then
            Address.Append('ห้อง ' + Component.Trim() + ' ');
        Component := this.GetHouseNumber(ResultJson);
        if Component <> '' then
            Address.Append('เลขที่ ' + Component.Trim() + ' ');
        Component := this.GetMooNumber(ResultJson);
        if Component <> '' then
            Address.Append('หมู่ ' + Component.Trim() + ' ');
        Component := this.GetSoiName(ResultJson);
        if Component <> '' then
            Address.Append('ซอย ' + Component.Trim() + ' ');

        Component := this.GetStreetName(ResultJson);
        if Component <> '' then
            Address.Append('ถนน ' + Component.Trim() + ' ');
#pragma warning disable AA0139
        Address1 := Address.ToText();
#pragma warning restore AA0139


        Component := this.GetPostCode(ResultJson);
        if Component <> '' then
#pragma warning disable AA0139
            PostCode := Component.Trim();
#pragma warning restore AA0139

        Component := this.GetThambol(ResultJson);
        if Component <> '' then
            Subdistrict := Component.Trim();
        Component := this.GetAmphur(ResultJson);
        if Component <> '' then
            District := Component.Trim();
        Component := this.GetProvince(ResultJson);
        if Component <> '' then
#pragma warning disable AA0139
            Province := Component.Trim();
#pragma warning restore AA0139

        if copystr(Postcode, 1, 1) = '1' then begin
            Address2 := 'แขวง ' + Subdistrict;
            City := 'เขต ' + District;
        end else begin
            Address2 := 'ตำบล ' + Subdistrict;
            City := 'อำเภอ ' + District;
#pragma warning disable AA0139
            Province := 'จังหวัด ' + Province;
#pragma warning restore AA0139
        end;
    end;

    // ====================================================================
    // INTERNAL UTILITY FUNCTIONS
    // ====================================================================
    // These are helper functions used internally by the codeunit for
    // JSON processing, XML parsing, and debug operations
    // ====================================================================

    /// <summary>
    /// Internal helper to extract values from JSON object safely
    /// ฟังก์ชันสำหรับดึงค่าจาก JSON object อย่างปลอดภัย
    /// </summary>
    /// <param name="ResultJson">JSON object to search in</param>
    /// <param name="KeyName">Key name to look for</param>
    /// <returns>Text value if key exists, empty string otherwise</returns>
    local procedure GetJsonValue(ResultJson: JsonObject; KeyName: Text): Text
    var
        Token: JsonToken;
    begin
        if ResultJson.Get(KeyName, Token) then
            exit(Token.AsValue().AsText())
        else
            exit('');
    end;

    /// <summary>
    /// Robust XML child text extraction with multiple fallback strategies
    /// 
    /// This function tries multiple approaches to extract text from XML child elements:
    /// 1. Direct child search
    /// 2. Descendant search (recursive)  
    /// 3. Local-name search (ignores namespaces)
    /// 
    /// This multi-layered approach ensures data extraction works even when
    /// XML namespace handling becomes complex.
    /// 
    /// ฟังก์ชันสำหรับดึงข้อความจาก XML child element แบบมีหลายวิธี fallback
    /// </summary>
    /// <param name="Parent">Parent XML node to search in</param>
    /// <param name="LocalName">Name of child element to find</param>
    /// <returns>Text content of child element or empty string if not found</returns>
    local procedure GetSimpleChildText(Parent: XmlNode; LocalName: Text): Text
    var
        Child: XmlNode;
        XmlElem: XmlElement;
    begin
        // Strategy 1: Try direct child element search
        if Parent.SelectSingleNode(LocalName, Child) then begin
            if Child.IsXmlElement then begin
                XmlElem := Child.AsXmlElement();
                exit(XmlElem.InnerText);
            end;
        end;

        // Strategy 2: Try descendant search (searches all levels down)
        if Parent.SelectSingleNode('.//' + LocalName, Child) then begin
            if Child.IsXmlElement then begin
                XmlElem := Child.AsXmlElement();
                exit(XmlElem.InnerText);
            end;
        end;

        // Strategy 3: Try local-name approach (ignores XML namespaces)
        // This is often needed when XML response has unexpected namespace declarations
        if Parent.SelectSingleNode('.//*[local-name()="' + LocalName + '"]', Child) then begin
            if Child.IsXmlElement then begin
                XmlElem := Child.AsXmlElement();
                exit(XmlElem.InnerText);
            end;
        end;

        // If all strategies fail, return empty string
        exit('');
    end;

    /// <summary>
    /// Debug helper to get XML content as text for troubleshooting
    /// 
    /// Converts an XML node and all its children to text format for inspection.
    /// Used in debug scenarios to see the actual XML structure when parsing fails.
    /// 
    /// ฟังก์ชันสำหรับแปลง XML node เป็นข้อความเพื่อ debug
    /// </summary>
    /// <param name="Node">XML node to convert to text</param>
    /// <returns>String representation of the XML node</returns>

    /// <summary>
    /// XML encoding function to safely embed text in SOAP envelope
    /// 
    /// Encodes special characters that have meaning in XML to their entity equivalents:
    /// ampersand to &amp;, less-than to &lt;, greater-than to &gt;, quote to &quot;, apostrophe to &apos;
    /// 
    /// This prevents XML parsing errors when user input contains special characters.
    /// 
    /// ฟังก์ชันสำหรับ encode ข้อความให้ปลอดภัยใน XML
    /// </summary>
    /// <param name="Value">Text to encode</param>
    /// <returns>XML-safe encoded text</returns>
    local procedure XmlEncode(Value: Text): Text
    begin
        // Encode XML special characters to prevent parsing errors
        Value := Value.Replace('&', '&amp;');   // Must be first to avoid double-encoding
        Value := Value.Replace('<', '&lt;');    // Less-than symbol
        Value := Value.Replace('>', '&gt;');    // Greater-than symbol  
        Value := Value.Replace('"', '&quot;');  // Double quote
        Value := Value.Replace('''', '&apos;'); // Single quote/apostrophe
        exit(Value);
    end;

    internal procedure ValidateContactDatafromRD(ContactNo: Code[20]; VatID: Code[13]; BranchCode: Code[20])
    var
        Contact: Record Contact;
        Address1: text[100];
        Address2: text[50];
        City: text[30];
        Province: text[30];
        PostCode: code[20];
        TitleName: Text;
        ContactName: Text;
        SurName: Text;
        FullContactName: Text;
        ErrMsg: Text;
    begin
        this.SetVATID(VatID, BranchCode);
        this.GetDatafromRDweb(this.GlobalVATID, this.GlobalBranchNo);

        ErrMsg := this.GetErrorMessage(this.GlobalJo);
        if ErrMsg <> '' then
            Error(ErrMsg);

        // เลขประจำตัวผู้เสียภาษี 13 หลัก (NID)
        // เลขที่สาขา (BranchNumber)
        // คำนำหน้าชื่อ (BranchTitle)
        // ชื่อสถานประกอบการ (BranchName)
        // ชื่ออาคาร (BuildingName)
        // ห้องที่ (RoomNumber)
        // ชั้นที่ (FloorNumber)
        // หมู่บ้าน (VillageName)
        // เลขที่ตั้งของสถานประกอบการ (HouseNumber)
        // หมู่ที่ (MooNumber)
        // ซอย (SoiName)
        // ถนน (StreetName)
        // ตำบล (ThumbolName)
        // อำเภอ (AmphurName)
        // จังหวัด (ProvinceName)
        // รหัสไปรษณีย์ (PostCode)

        if Contact.Get(ContactNo) then begin
#pragma warning disable AA0139
            TitleName := this.GetCompanyTitleName(this.GlobalJo);
            TitleName := TitleName.Trim();
            ContactName := this.GetCompanyName(this.GlobalJo);
            ContactName := ContactName.Trim();
            SurName := this.GetCompanySurname(this.GlobalJo);
            SurName := SurName.Trim();
            if TitleName <> '' then
                FullContactName := TitleName + ' ';
            if ContactName <> '' then
                FullContactName := FullContactName + ContactName + ' ';
            if SurName <> '' then
                FullContactName := FullContactName + SurName;

            contact.Name := FullContactName;
            this.GetFullAddress(this.GlobalJo, Address1, Address2, City, Province, PostCode);
            Contact.Address := Address1.Trim();
            Contact."Address 2" := Address2.Trim();
            Contact.City := City.Trim();
            Contact.County := Province.Trim();
#pragma warning restore AA0139
            Contact."Post Code" := PostCode;
            Contact.Modify();
            Message('Contact %1 updated successfully.', ContactNo);
        end;
    end;

    // ====================================================================
    // GLOBAL VARIABLES
    // ====================================================================

    var
        GlobalVATID: Code[13];
        GlobalBranchNo: Integer;
        GlobalJo: JsonObject;
        GlobalSuccess: Boolean;
}
