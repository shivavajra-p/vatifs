## IFS RD VAT Service (Thai Revenue Department VAT Validation)

AL codeunit that validates Thai VAT (Tax Identification Number / TIN – 13 digits) and retrieves company / branch address data directly from the Revenue Department SOAP (v3) service.

### Key Features
* SOAP 1.1 request builder (proper namespaces + SOAPAction header)
* Single call validation: `CheckVatOnce(TIN, BranchNo, Username, Password, ResultJson)`
* Helper wrappers for every returned field (company name, branch name/number, address parts, first registration date, error message)
* Robust XML parsing with namespace‑agnostic fallback (local-name() queries)
* Address composition utilities (full address and split address lines) with Thai labeling (ตำบล / แขวง, อำเภอ / เขต, จังหวัด)
* Input validation (13‑digit VAT ID, 5‑digit branch code or “สำนักงานใหญ่” -> 0)
* Centralized JSON extraction helpers
* Contact record enrichment (`ValidateContactDatafromRD`) updating: Name, Address, Address 2, City, Province, Post Code, validation timestamp & user
* Safe truncation / overflow handling for AL field lengths

### Core Procedures
| Category | Procedure | Purpose |
|----------|-----------|---------|
| Setup | `SetVATID` | Stores and validates VAT ID + branch code |
| Validation | `ValidateBranchCode` | Normalizes & converts branch textual code to Integer |
| Service | `CheckVatOnce` | Performs SOAP call & fills JSON result |
| Parsing | `ParseResponseToJson` | XML -> JSON field mapping |
| Address | `GetFullAddress`, `GetFullAddressTest` | Build formatted Thai address variants |
| Contact Integration | `ValidateContactDatafromRD` | Fetch + push data into Contact record |
| Accessors | `GetVatId`, `GetCompanyName`, `GetProvince`, etc. | Typed field getters |
| Utility | `XmlEncode`, `GetJsonValue`, `GetSimpleChildText` | Internal helpers |

### Data Fields Captured (selected)
VAT / Identity: vNID, vtin, vtitleName, vName, vSurname
Branch: vBranchTitleName, vBranchName, vBranchNumber
Address granular: vBuildingName, vFloorNumber, vRoomNumber, vHouseNumber, vVillageName, vMooNumber, vSoiName, vStreetName, vThambol, vAmphur, vProvince, vPostCode, vYaek
Business meta: vBusinessFirstDate
Status: vmsgerr, success (added internally), raw (full XML)

### Usage (Basic)
```al
var
	VatService: Codeunit "IFS RD VAT Service";
	Result: JsonObject;
	Ok: Boolean;
begin
	VatService.SetVATID('0123456789012', '00001'); // or 'สำนักงานใหญ่' for HQ
	Ok := VatService.CheckVatOnce('0123456789012', 1, 'anonymous', 'anonymous', Result);
	if Ok and VatService.IsSuccess(Result) then
		Message(VatService.GetCompanyName(Result));
end;
```

### Contact Enrichment
Call `ValidateContactDatafromRD(ContactNo, VatID, BranchCode)` to auto-update a Contact with validated information. Errors from RD (vmsgerr) raise an AL error.

### SOAP Endpoint
Production (as coded):
`https://rdws.rd.go.th/serviceRD3/vatserviceRD3.asmx`

### Validation Rules
* VAT ID must be exactly 13 numeric characters.
* Branch: 5 numeric digits (leading zeros preserved in source text) or literal `สำนักงานใหญ่` -> head office (0).

### Error Handling
* Network / HTTP failure => returns FALSE from `CheckVatOnce`.
* Non-success HTTP status codes captured in JSON (httpStatus + raw).
* Missing ServiceResult node yields JSON error entry + success = false.
* Downstream getters return empty string when field missing or placeholder '-'.

### Address Formatting Notes
* Bangkok districts: logic inspects first digit of Post Code (starting with '1') to choose แขวง / เขต vs ตำบล / อำเภอ.
* Two variants supplied: a single concatenated address and segmented Address1/Address2/City/Province/Post Code.

### Extensibility Ideas
* Add caching (table keyed by VAT+Branch with timestamp)
* Add retry/backoff for transient HTTP errors
* Add unit tests for parsing edge-cases (namespace changes, placeholder '-')
* Support alternative search parameters (Name + Province when TIN unknown)

### Prerequisites
* Microsoft Dynamics 365 Business Central AL environment
* Permissions to call external web services (HTTP)

### License / Attribution
Add your chosen license (e.g., MIT) plus any required attribution here.

---
Short summary: This codeunit wraps the Thai RD VAT SOAP service, validates TIN + branch, converts XML to structured JSON, and exposes clean helper methods plus optional Contact synchronization.

### UI / UX Integration
The solution includes a page extension `IFS RDS Contact Card` (ID 80200) that enhances the standard Contact Card:
1. Adds a new FastTab group under the Communication area named “RD VAT Service”.
2. Displays two read‑only fields:
	* RD Validate Date – last successful validation timestamp.
	* RD Validate By – user who performed the validation.
3. Provides an action button: “Get Data from RD VAT Service”.
	* Invokes `ValidateContactDatafromRD(ContactNo, VatID, BranchCode)`.
	* Pulls VAT + Branch data and updates: Name, Address, Address 2, City, Province, Post Code, validation meta.
4. Includes a promoted action reference for quick Ribbon access.

### Recommended UI Enhancements (Optional)
* Add a FactBox / Cue to show validation status (Success / Error / Last Checked Age).
* Surface vmsgerr as a non-blocking notification instead of a hard error for user re‑try.
* Add a Branch Code input (if not already visible) with on-validate formatting.
* Provide a “View Raw Response” action (opens a temporary page with XML / JSON for diagnostics).
* Introduce a progress indicator (Page Processing) during the SOAP round trip.
* Implement permissions: separate permission set for calling external RD service.

### UX Principles Applied
* Read-only historical fields to prevent accidental tampering.
* Action placed near related data (Contact context) to reduce navigation friction.
* Clear, concise captions & tooltips; easy to localize later (add ML captions).
* Error isolation: network / parsing issues don’t silently modify data.

### Future UI Ideas
* Badge indicator showing how many days since last verification.
* Batch validate from a list page (multi-select contacts) with a background job queue.
* Telemetry (count of calls, failures, average latency) via AL events.
