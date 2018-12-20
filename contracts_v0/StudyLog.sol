pragma solidity ^0.4.24;

contract StudyLog {
    
    address public Controller;
    address public Owner;
    address public Editor;
    
    mapping (address => bool) managerTag;
    address[] public ManagerList;
    
    
    constructor() public {
        Controller = msg.sender;
        Owner = msg.sender;
        managerTag[msg.sender] = true;
        ManagerList.push(msg.sender);
    }
    
    
    function grantManagement(address newManager) public onlyManager {
        if (!managerTag[newManager]) {
            ManagerList.push(newManager);
            managerTag[newManager] = true;
        }
    }
    
    function depriveManagement(address certainManager) public onlyManager {
        if (managerTag[certainManager]) {
            for (uint i = 0; i<ManagerList.length; i++) {
                if (ManagerList[i] == certainManager) {
                    ManagerList[i] = ManagerList[ManagerList.length - 1];  //Do this firstly.
                    ManagerList.length--;  //Can not reduce the length at first, or it may lead to error when length is 1.
                    break;
                }
            }
            managerTag[certainManager] = false;
        }
    }
    
    function isManager(address _addr) public view returns(bool) {
        return managerTag[_addr];
    }
    
    
/* Modifiers */

    modifier onlyOwner {
        if (msg.sender != Owner) revert();
        _;
    }

    modifier onlyController {
        if (msg.sender != Controller) revert();
        _;
    }
    
    modifier onlyEditor {
        if (msg.sender != Editor) revert();
        _;
    }
    
    modifier onlyManager {
        if (!managerTag[msg.sender]) revert();
        _;
    }
    
    // set the address of controller contract
    
    event SetController(address newController);
    
    function setController (address _Controller) onlyOwner public returns(bool) {
        Controller = _Controller;
        emit SetController(_Controller);
        return true;
    }
    
    event TransferOwnerShip(address newOwner);
    
    function transferOwnerShip(address _newOwner) onlyOwner public returns(bool) {
        Owner = _newOwner;
        emit TransferOwnerShip(_newOwner);
        return true;
    }
    
    event SetOwner(address newOwner);
    
    function setOwner(address _newOwner) onlyController public returns(bool) {
        Owner = _newOwner;
        emit SetOwner(_newOwner);
        return true;
    }
    
    event SetEditor(address newEditor);
    
    function setEditor(address _newEditor) onlyOwner public returns(bool) {
        Editor = _newEditor;
        emit SetEditor(_newEditor);
        return true;
    }
    
    
/* Practical Events */

/* -----------------------------------------------------*/
    event AddStuInfo(string Txid, bool Success, address Operator);
    
    struct struct_addStuInfo {
        string Txid;
        bool Success;
        address Operator;
        uint StudentID;
        string StudentName;
        uint StudentClass;
    }
    
    mapping (string => struct_addStuInfo) map_addStuInfo;
    
    function addStuInfo(string _Txid, bool _Success, address _Operator, uint _StudentID, string _StudentName, uint _StudentClass)
    onlyEditor public {
        map_addStuInfo[_Txid].Txid = _Txid;
        map_addStuInfo[_Txid].Success = _Success;
        map_addStuInfo[_Txid].Operator = _Operator;
        map_addStuInfo[_Txid].StudentID = _StudentID;
        map_addStuInfo[_Txid].StudentName = _StudentName;
        map_addStuInfo[_Txid].StudentClass = _StudentClass;
        emit AddStuInfo(_Txid, _Success, _Operator);
    }
    
    function get_addStuInfo(string _Txid) onlyManager public view
    returns(string Txid, bool Success, address Operator, uint StudentID, string StudentName, uint StudentClass) {
        Txid = map_addStuInfo[_Txid].Txid;
        Success = map_addStuInfo[_Txid].Success;
        Operator = map_addStuInfo[_Txid].Operator;
        StudentID = map_addStuInfo[_Txid].StudentID;
        StudentName = map_addStuInfo[_Txid].StudentName;
        StudentClass = map_addStuInfo[_Txid].StudentClass;
    }
    
    
/* -----------------------------------------------------*/

    event AddTeacherInfo(string Txid, bool Success, address Operator);
    
    struct struct_AddTeacherInfo {
        string Txid;
        bool Success;
        address Operator;
        uint TeacherID;
        string TeacherName;
    }
    
    mapping (string => struct_AddTeacherInfo) map_AddTeacherInfo;
    
    function addTeacherInfo(string _Txid, bool _Success, address _Operator, uint _TeacherID, string _TeacherName)
    onlyEditor public {
        map_AddTeacherInfo[_Txid].Txid =_Txid ;
        map_AddTeacherInfo[_Txid].Success =_Success ;
        map_AddTeacherInfo[_Txid].Operator =_Operator ;
        map_AddTeacherInfo[_Txid].TeacherID =_TeacherID ;
        map_AddTeacherInfo[_Txid].TeacherName =_TeacherName ;
        emit AddTeacherInfo(_Txid, _Success, _Operator);
    }
    
    function get_addTeacherInfo(string _Txid) onlyManager public view
    returns(string Txid, bool Success, address Operator, uint TeacherID, string TeacherName) {
        Txid = map_AddTeacherInfo[_Txid].Txid;
        Success = map_AddTeacherInfo[_Txid].Success;
        Operator = map_AddTeacherInfo[_Txid].Operator;
        TeacherID = map_AddTeacherInfo[_Txid].TeacherID;
        TeacherName = map_AddTeacherInfo[_Txid].TeacherName;
    }
    
    
/* -----------------------------------------------------*/
    
    event AddCourseInfo(string Txid, bool Success, address Operator);
    
    struct struct_addCourseInfo {
        string Txid;
        bool Success;
        address Operator;
        uint CourseID;
        string CourseName;
        bool Compulsory;  //课程属性，是否必修
        uint Term;  //学期号,筛选课程成绩时使用
        uint Credit;
        uint[] Percentage;  //课程的成绩组成
        uint TeacherID;
    }
    
    mapping (string => struct_addCourseInfo) map_addCourseInfo;
    
    function addCourseInfo(string _Txid, bool _Success, address _Operator, uint _CourseID,
    string _CourseName, bool _Compulsory, uint _Term, uint _Credit, uint[] _Percentage, uint _TeacherID)
    onlyEditor public {
        addCourseInfo_tmp.Txid = _Txid;
        addCourseInfo_tmp.Success = _Success;
        addCourseInfo_tmp.Operator = _Operator;
        addCourseInfo_tmp.CourseID = _CourseID;
        addCourseInfo_tmp.CourseName = _CourseName;
        addCourseInfo_tmp.Compulsory = _Compulsory;
        addCourseInfo_tmp.Term = _Term;
        addCourseInfo_tmp.Credit = _Credit;
        addCourseInfo_tmp.Percentage = _Percentage;
        addCourseInfo_tmp.TeacherID = _TeacherID;
        map_addCourseInfo[_Txid] = addCourseInfo_tmp;
        emit AddCourseInfo(_Txid, _Success, _Operator);
    }
    
    struct_addCourseInfo private addCourseInfo_tmp;
    
    function get_addCourseInfo(string _Txid) onlyManager public view
    returns(string Txid, bool Success, address Operator, uint CourseID,
    string CourseName, bool Compulsory, uint Term, uint Credit, uint[] Percentage, uint TeacherID) {
        struct_addCourseInfo storage si = map_addCourseInfo[_Txid];
        uint[] memory a = si.Percentage;
        Txid = si.Txid;
        Success = si.Success;
        Operator = si.Operator;
        CourseID = si.CourseID;
        CourseName = si.CourseName;
        Compulsory = si.Compulsory;
        Term = si.Term;
        Credit = si.Credit;
        Percentage = a;
        TeacherID = si.TeacherID;
    }
    
    

/* -----------------------------------------------------*/

    event AddManagerInfo(string Txid, bool Success, address Operator);
    
    struct struct_AddManagerInfo {
        string Txid;
        bool Success;
        address Operator;
        uint ManagerID;
    }
    
    mapping (string => struct_AddManagerInfo) map_AddManagerInfo;
    
    function addManagerInfo(string _Txid, bool _Success, address _Operator, uint _ManagerID)
    onlyEditor public {
        map_AddManagerInfo[_Txid].Txid = _Txid;
        map_AddManagerInfo[_Txid].Success = _Success;
        map_AddManagerInfo[_Txid].Operator = _Operator;
        map_AddManagerInfo[_Txid].ManagerID = _ManagerID;
        emit AddManagerInfo(_Txid, _Success, _Operator);
    }
    
    function get_addManagerInfo(string _Txid) onlyManager public view
    returns(string Txid, bool Success, address Operator, uint ManagerID) {
        Txid = map_AddManagerInfo[_Txid].Txid;
        Success = map_AddManagerInfo[_Txid].Success;
        Operator = map_AddManagerInfo[_Txid].Operator;
        ManagerID = map_AddManagerInfo[_Txid].ManagerID;
    }
    


/* -----------------------------------------------------*/
    
    event AddAccount(string Txid, bool Success, address Operator);
    
    struct struct_AddAccount {
        string Txid;
        bool Success;
        address Operator;
        uint Identity;
        uint ID;
        address Addr;
    }
    
    mapping (string => struct_AddAccount) map_AddAccount;
    
    function addAccount(string _Txid, bool _Success, address _Operator, uint _Identity, uint _ID, address _Addr)
    onlyEditor public {
        map_AddAccount[_Txid].Txid = _Txid;
        map_AddAccount[_Txid].Success = _Success;
        map_AddAccount[_Txid].Operator = _Operator;
        map_AddAccount[_Txid].Identity = _Identity;
        map_AddAccount[_Txid].ID = _ID;
        map_AddAccount[_Txid].Addr = _Addr;
        emit AddAccount(_Txid, _Success, _Operator);
    }
    
    function get_addAccount(string _Txid) onlyManager public view
    returns(string Txid, bool Success, address Operator, uint Identity, uint ID, address Addr) {
        Txid = map_AddAccount[_Txid].Txid;
        Success = map_AddAccount[_Txid].Success;
        Operator = map_AddAccount[_Txid].Operator;
        Identity = map_AddAccount[_Txid].Identity;
        ID = map_AddAccount[_Txid].ID;
        Addr = map_AddAccount[_Txid].Addr;
    }
    
    
    
/* -----------------------------------------------------*/
    
    event SetStuMark(string Txid, bool Success, address Operator);
    
    struct struct_SetStuMark {
        string Txid;
        bool Success;
        address Operator;
        uint TeacherID;
        uint CourseID;
        uint StudentID;
        uint[] Marks;  //成绩的数值应是原成绩的1000倍
    }
    
    mapping (string => struct_SetStuMark) map_SetStuMark;
    
    function setStuMark(string _Txid, bool _Success, address _Operator, uint _TeacherID, uint _CourseID, uint _StudentID, uint[] _Marks)
    onlyEditor public {
        SetStuMark_tmp.Txid = _Txid;
        SetStuMark_tmp.Success = _Success;
        SetStuMark_tmp.Operator = _Operator;
        SetStuMark_tmp.TeacherID = _TeacherID;
        SetStuMark_tmp.CourseID = _CourseID;
        SetStuMark_tmp.StudentID = _StudentID;
        SetStuMark_tmp.Marks = _Marks;
        map_SetStuMark[_Txid] = SetStuMark_tmp;
        emit SetStuMark(_Txid, _Success, _Operator);
    }
    
    struct_SetStuMark private SetStuMark_tmp;
    
    function get_setStuMark(string _Txid) onlyManager public view
    returns(string Txid, bool Success, address Operator, uint TeacherID, uint CourseID, uint StudentID, uint[] Marks) {
        struct_SetStuMark storage si = map_SetStuMark[_Txid];
        uint[] memory a = si.Marks;
        Txid = si.Txid;
        Success = si.Success;
        Operator = si.Operator;
        TeacherID = si.TeacherID;
        CourseID = si.CourseID;
        StudentID = si.StudentID;
        Marks = a;
    }
    


/* -----------------------------------------------------*/

    event StuChooseCourse(string Txid, bool Success, address Operator);
    
    struct struct_StuChooseCourse {
        string Txid;
        bool Success;
        address Operator;
        uint CourseID;
        uint StudentID;
        uint requestTime;  //学生发出选课请求的时间戳，由前端提供
    }
    
    mapping (string => struct_StuChooseCourse) map_StuChooseCourse;
    
    function stuChooseCourse(string _Txid, bool _Success, address _Operator, uint _CourseID, uint _StudentID, uint _requestTime)
    onlyEditor public {
        map_StuChooseCourse[_Txid].Txid = _Txid;
        map_StuChooseCourse[_Txid].Success = _Success;
        map_StuChooseCourse[_Txid].Operator = _Operator;
        map_StuChooseCourse[_Txid].CourseID = _CourseID;
        map_StuChooseCourse[_Txid].StudentID = _StudentID;
        map_StuChooseCourse[_Txid].requestTime = _requestTime;
        emit StuChooseCourse(_Txid, _Success, _Operator);
    }
    
    function get_stuChooseCourse(string _Txid) onlyManager public view
    returns(string Txid, bool Success, address Operator, uint CourseID, uint StudentID, uint requestTime) {
        Txid = map_StuChooseCourse[_Txid].Txid;
        Success = map_StuChooseCourse[_Txid].Success;
        Operator = map_StuChooseCourse[_Txid].Operator;
        CourseID = map_StuChooseCourse[_Txid].CourseID;
        StudentID = map_StuChooseCourse[_Txid].StudentID;
        requestTime = map_StuChooseCourse[_Txid].requestTime;
    }
    
    
}