## IFS RD VAT Service (Thai VAT Data Lookup & Auto-Fill)

### What this is
This tool lets you quickly confirm a Thai 13‑digit tax ID (VAT/TIN) and pull the official business / branch address directly from the Revenue Department, then auto‑fill a Contact in Business Central. No more copying from a website or guessing the branch status.

### Why you would use it
* Validate a new customer or vendor before onboarding
* Ensure invoices carry an official, standardized legal name & address
* Distinguish Head Office vs Branch (branch 0 vs branch number)
* Reduce manual typing and spelling inconsistencies
* Keep an audit trail of who validated and when

### Simple flow
1. Enter Tax ID + Branch Code (or mark as Head Office)
2. Press the action button
3. Service call goes out to the Revenue Department
4. Response is interpreted (success / warning / not found)
5. Cleaned data fills the Contact fields and the validation timestamp is stored

### Key data returned
Identity:
* Tax ID (13 digits)
* Name / Branch name / Title (when available)

Address (only the parts the authority returns):
* Building / Floor / Room
* Number / Moo / Soi / Street
* Sub‑district (ตำบล / แขวง) – auto‑labelled
* District (อำเภอ / เขต)
* Province
* Post Code

Other:
* Business start date (if provided)
* Message field (errors / remarks)

### Basic usage (concept)
```al
VatService.SetVATID('0123456789012', '00001');
// Then call the action (or code) to fetch and map the data.
```
End users usually just click “Get Data from RD VAT Service” on the Contact Card.

### Validation rules
* Tax ID must be exactly 13 numeric digits
* Branch code = 5 digits OR the word “สำนักงานใหญ่” (Head Office -> 0)

### What it changes on a Contact
* Name (combined properly if title / surname present)
* Address, Address 2, City, Province, Post Code
* Validation Date & Validated By user

### On‑screen integration
A page extension adds a group “RD VAT Service” with:
* RD Validate Date (read‑only)
* RD Validate By (read‑only)
* Action: Get Data from RD VAT Service (fetch + fill)

### Business benefits
| Common issue | Improvement |
|--------------|-------------|
| Wrong legal name on invoice | Uses authoritative name |
| Inconsistent address wording | Standard formatting applied |
| Branch misclassified | Explicit branch number normalized |
| Hard to prove validation | Timestamp + user stored |
| Repeated manual lookups | One‑click retrieval |

### Limitations
* Requires internet access
* If the external service is down, no data can be fetched at that moment
* Some fields may return blank if not held by the authority

### Future improvement ideas
* Batch / list page multi‑select validation
* History log (change tracking of retrieved values)
* Automatic periodic re‑validation for key accounts
* Search by Name + Province when Tax ID unknown

### Quick technical note (kept minimal)
Under the hood it calls the official SOAP endpoint:
`https://rdws.rd.go.th/serviceRD3/vatserviceRD3.asmx`
Parses the XML, shields you from raw structure differences, and exposes clean getters.

### Quick error behavior
* Network failure: no update, user informed
* Invalid response: flagged, no partial write
* Error message from authority: surfaced to user

### Example AL snippet (expanded)
```al
var
	Service: Codeunit "IFS RD VAT Service";
	Data: JsonObject;
	Ok: Boolean;
begin
	Service.SetVATID('0123456789012', '00001');
	Ok := Service.CheckVatOnce('0123456789012', 1, 'anonymous', 'anonymous', Data);
	if Ok and Service.IsSuccess(Data) then
		Message(Service.GetCompanyName(Data))
	else
		Message('Lookup failed.');
end;
```

### UI / UX enhancement ideas
* Status badge: “Verified X days ago”
* Non‑blocking notification (instead of hard error) for transient issues
* “View Raw Data” diagnostic action for admins
* Progress indicator while waiting for the service call

### Prerequisites
* Business Central environment (AL)
* Permission to call external HTTP services

### License
Add your preferred license (e.g., MIT) here.

---
In one line: Verify a Thai tax ID, pull the real branch + address, and fill your Contact cleanly—fast and repeatable.
