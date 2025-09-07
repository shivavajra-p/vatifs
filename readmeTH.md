## IFS RD VAT Service (บริการตรวจสอบภาษีมูลค่าเพิ่ม กรมสรรพากร)

โค้ดยูนิต AL สำหรับตรวจสอบเลขประจำตัวผู้เสียภาษี (TIN 13 หลัก) ของไทย และดึงข้อมูลชื่อ/ที่อยู่/ข้อมูลสาขา จาก Web Service (SOAP v3) ของกรมสรรพากรโดยตรง

### จุดเด่น (Key Features)
* ส่งคำขอผ่าน SOAP 1.1 (ปรับ Header / SOAPAction ถูกต้อง)
* ฟังก์ชันตรวจสอบครั้งเดียว: `CheckVatOnce(TIN, BranchNo, Username, Password, ResultJson)`
* มีฟังก์ชัน Helper แยกแต่ละฟิลด์ (ชื่อบริษัท ชื่อสาขา เลขสาขา ส่วนที่อยู่ วันที่เริ่มธุรกิจ ข้อความผิดพลาด)
* กลไกแปลง XML -> JSON รองรับ Namespace ผิดปกติ (ใช้ local-name() fallback)
* ฟังก์ชันประกอบที่อยู่ (เต็ม / แบ่งบรรทัด) พร้อมป้ายกำกับไทย (ตำบล/แขวง, อำเภอ/เขต, จังหวัด)
* ตรวจสอบความถูกต้องของอินพุต (VAT 13 หลัก, รหัสสาขา 5 หลัก หรือ 'สำนักงานใหญ่')
* ฟังก์ชันอ่านค่า JSON ที่ปลอดภัย (คืนค่าว่างถ้าไม่มี)
* อัปเดตข้อมูลลง Contact (`ValidateContactDatafromRD`) เช่น ชื่อ ที่อยู่ รหัสไปรษณีย์ วันที่ตรวจสอบ ผู้ตรวจสอบ
* ป้องกันข้อมูลยาวเกินฟิลด์ (ตัดข้อความตาม MaxStrLen)

### ฟังก์ชันหลัก (Core Procedures)
| หมวด | ชื่อ | หน้าที่ |
|------|------|---------|
| ตั้งค่า | `SetVATID` | เก็บและตรวจสอบ VAT + BranchCode |
| ตรวจสอบ | `ValidateBranchCode` | แปลงรหัสสาขาเป็นตัวเลข / HQ = 0 |
| เรียกบริการ | `CheckVatOnce` | เรียก SOAP และคืน JSON |
| แปลงผล | `ParseResponseToJson` | XML -> JSON field mapping |
| ที่อยู่ | `GetFullAddress`, `GetFullAddressTest` | สร้างรูปแบบที่อยู่ไทย |
| Contact | `ValidateContactDatafromRD` | เติมข้อมูลลง Contact |
| Getter | `GetVatId` ฯลฯ | คืนค่าฟิลด์เฉพาะ |
| Utility | `XmlEncode`, `GetJsonValue`, `GetSimpleChildText` | เครื่องมือภายใน |

### ฟิลด์ข้อมูลที่ดึงมา (บางส่วน)
VAT / Identification: vNID, vtin, vtitleName, vName, vSurname
สาขา: vBranchTitleName, vBranchName, vBranchNumber
ที่อยู่ละเอียด: vBuildingName, vFloorNumber, vRoomNumber, vHouseNumber, vVillageName, vMooNumber, vSoiName, vStreetName, vThambol, vAmphur, vProvince, vPostCode, vYaek
อื่น ๆ: vBusinessFirstDate, vmsgerr, success (เพิ่มภายใน), raw (XML เต็ม)

### ตัวอย่างการใช้งานพื้นฐาน
```al
var
	VatService: Codeunit "IFS RD VAT Service";
	Result: JsonObject;
	Ok: Boolean;
begin
	VatService.SetVATID('0123456789012', '00001');
	Ok := VatService.CheckVatOnce('0123456789012', 1, 'anonymous', 'anonymous', Result);
	if Ok and VatService.IsSuccess(Result) then
		Message(VatService.GetCompanyName(Result));
end;
```

### เติมข้อมูลลง Contact
เรียก `ValidateContactDatafromRD(ContactNo, VatID, BranchCode)` เพื่อดึงข้อมูลและอัปเดต Contact อัตโนมัติ (หาก vmsgerr มีค่า จะ Error)

### Endpoint SOAP
`https://rdws.rd.go.th/serviceRD3/vatserviceRD3.asmx`

### กฎการตรวจสอบ (Validation Rules)
* VAT ID ต้องมี 13 หลักเป็นตัวเลขเท่านั้น
* รหัสสาขา 5 หลัก (ตัวเลข) หรือคำว่า `สำนักงานใหญ่` = 0

### การจัดการข้อผิดพลาด
* HTTP / Network ล้มเหลว => `CheckVatOnce` คืน FALSE
* สถานะ HTTP ผิดปกติ => เก็บ httpStatus + raw ใน JSON
* หา ServiceResult ไม่เจอ => success=false + error message
* Getter คืนค่าว่างเมื่อข้อมูลเป็น '-' หรือไม่มี

### รูปแบบที่อยู่
* ถ้าเลขรหัสไปรษณีย์ขึ้นต้นด้วย '1' (เขตกรุงเทพฯ) จะใช้ แขวง / เขต แทน ตำบล / อำเภอ
* มีทั้งรูปแบบบรรทัดเดียว (Full) และแบบแยก Address1, Address2, City, Province, PostCode

### แนวทางพัฒนาต่อ
* แคชผลลัพธ์ตาม (VAT+Branch) พร้อมวันหมดอายุ
* เพิ่ม Retry กรณี Timeout / 5xx
* เพิ่ม Automated Test สำหรับ XML edge cases
* รองรับค้นหาด้วยชื่อ + จังหวัด (ในอนาคต)

### ข้อกำหนดเบื้องต้น
* สภาพแวดล้อม Microsoft Dynamics 365 Business Central (AL)
* สิทธิ์เรียกออก HTTP

### License / การใช้งานซ้ำ
เพิ่มรายละเอียด License (เช่น MIT) และ Attribution หากต้องการ

---
สรุป: โค้ดชุดนี้ช่วยตรวจสอบ VAT ไทยผ่าน SOAP ของกรมสรรพากร แปลงผลเป็น JSON ให้ฟังก์ชัน Getter ชัดเจน และผนวกข้อมูลเข้ากับ Contact ได้สะดวก

### มุมมองด้าน UI (User Interface)
ส่วนติดต่อผู้ใช้ที่ผนวกในระบบอยู่ใน Page Extension: `IFS RDS Contact Card` (รหัส 80200) ซึ่งขยายหน้า Contact Card เดิม โดยเพิ่ม:
1. กลุ่มใหม่ (Group) ชื่อ “RD VAT Service” ใน FastTab Communication เพื่อแสดงข้อมูลตรวจสอบล่าสุด
2. ฟิลด์แสดงผลแบบ Read‑Only:
	* RD Validate Date – วันที่ตรวจสอบข้อมูลล่าสุดจากกรมสรรพากร
	* RD Validate By – ผู้ใช้ที่ดำเนินการตรวจสอบ
3. ปุ่มคำสั่ง (Action) “Get Data from RD VAT Service” อยู่หลัง “Apply Template” ทำงานดังนี้:
	* เรียก Codeunit `IFS RD VAT Service`
	* ใช้เลข Contact (“No.”), VAT Registration No., และ Branch Code (Rec.IFS_Branch_CRM) ในการดึงข้อมูล
	* เมื่อสำเร็จ ข้อมูลชื่อ/ที่อยู่/รหัสไปรษณีย์ จะถูกอัปเดตลงใน Contact พร้อม Timestamp + User
4. มี ActionRef สำหรับการ Promote (GetDataRDVATServicePromote) เพื่อให้เข้าถึงได้สะดวกใน Ribbon

แนวทางปรับปรุง UI เพิ่มเติม (ข้อเสนอ):
* แสดงสถานะ (Success / Error) ด้วย Cue หรือ FactBox
* เพิ่ม Field สำหรับใส่ Branch Code โดยตรง (ถ้ายังไม่มีบนหน้าจอ)
* แสดงข้อความผิดพลาดจาก vmsgerr ใน Dialog / Notification แทน Error (เพื่อไม่หยุด Flow)
* เพิ่ม Progress Indicator ระหว่างรอการตอบกลับ SOAP (เช่น Page Processing Indicator)
* เพิ่ม Action “Open Raw Response” เพื่อเปิดหน้า TextViewer แสดง XML/JSON สำหรับ Debug
* กำหนด Permission Set แยกสำหรับการกดปุ่มตรวจสอบภายนอก

หลัก UX ที่ใช้:
* ไม่ให้ผู้ใช้แก้ไขฟิลด์ประวัติ (ReadOnly) ลดความคลาดเคลื่อน
* ใช้ Caption/Tooltip เป็นภาษาอังกฤษ (สามารถปรับ Multi‑Language ต่อได้)
* วาง Action ใกล้พื้นที่ข้อมูลที่เกี่ยวข้อง (Communication) ลดการสแกนหา
