pragma solidity ^0.4.24;

import "./StudyLog.sol";

contract StudyData {

/* Codes about Authority and SuperUser */
    address public SuperUser;
    address public Owner;
    address public LogContract;
    
    StudyLog log = StudyLog(LogContract);

    struct Manager {
        uint ManagerID;
        address ManagerAddr;
    }
    mapping (uint => Manager) private managers;  //ManagerID => Manager
    mapping (address => bool) private managerTag;
    mapping (uint => bool) private managerIDTag;
    uint[] private ManagerList;  //storage ManagerID

/* Things about Data Structure */
    struct Course {
        uint CourseID;
        string CourseName;
        bool Compulsory;  //课程属性，是否必修
        uint Term;  //学期号,筛选课程成绩时使用
        uint Credit;
        uint[] Percentage;  //课程的成绩组成
        uint[] cStuIDs;  //CourseID => StudentID[], 已选该课程的学生号集合
        mapping(uint => bool) cStuIDsTag;
    }
    /* Indexs */
    mapping (uint => Course) private courses;  //CourseID => Course
    uint[] private CourseList;
    mapping (uint => bool) private courseIDTag;

    enum LearningProgress {
        NotStart, Start, PreviewStart, PreviewEnd, Test, NotPass, Pass
    }

    struct Stu_Course {
        uint CourseID;
        uint[] TestGrade;
        uint CourseGrade;
        LearningProgress Lp;
    }

    struct Student {
        uint StudentID;
        string StudentName;
        uint StudentClass;
        address StudentAddr;
        uint[] sCourseIDs;    //StudentID => CourseID[], index of "courses that student takes"
        uint[] sTermCourseIDs;  //学生某学期选中的所有课程的的集合
        mapping (uint => Stu_Course) stu_courses;  //CourseID => Course, Coureses that student takes.
        mapping (uint => uint) stu_choose_course_timestamp;
    }

    /* Indexs */
    mapping (uint => Student) private students;  //StudentID => Student
    mapping (address => bool) private studentTag;
    mapping (uint => bool) private studentIDTag;
    /*
    mapping (uint => string[]) private stuEvaluations;
    mapping (uint => string[]) private stuRPFiles;
    */
    uint[] private StudentList;

    mapping (uint => uint[]) private class_stu;  //StudentClass => StudentID[]

    struct Tch_Course {
        uint CourseID;

    }

    struct Teacher {
        uint TeacherID;
        string TeacherName;
        address TeacherAddr;
        uint[] tCourseIDs;
        mapping (uint => bool) tCourseIDsTag;
        mapping (uint => Tch_Course) tch_courses;
    }
    mapping (uint => Teacher) private teachers;
    mapping (address => bool) private teacherTag;
    mapping (uint => bool) private teacherIDTag;
    uint[] private TeacherList;


/* Function Codes */

    constructor() public {
        Owner = msg.sender;
        SuperUser = msg.sender;
        
    }


/* Functions for debug */

    function get_StudentList() onlyManager public view returns (uint[]) {
        uint[] memory list = StudentList;
        return list;
    }
    
    function get_TeacherList() onlyManager public view returns (uint[]) {
        uint[] memory list = TeacherList;
        return list;
    }
    
    function get_ManagerList() onlyManager public view returns (uint[]) {
        uint[] memory list = ManagerList;
        return list;
    }

    function get_CourseList() onlyManager public view returns (uint[]) {
        uint[] memory list = CourseList;
        return list;
    }
    
    function get_ClassStuIDs(uint _ClassID) onlyManager public view returns (uint[]) {
        uint[] memory list = class_stu[_ClassID];
        return list;
    }
    
    function get_Student(uint _StudentID) onlyManager public view
    returns (uint StudentID, string StudentName, uint StudentClass, address StudentAddr, uint[] sCourseIDs, uint[] sTermCourseIDs) {
        Student storage si = students[_StudentID];
        uint[] memory a = si.sCourseIDs;
        uint[] memory b = si.sTermCourseIDs;
        StudentID = si.StudentID;
        StudentName = si.StudentName;
        StudentClass = si.StudentClass;
        StudentAddr = si.StudentAddr;
        sCourseIDs = a;
        sTermCourseIDs = b;
    }
    
    function get_SC(uint _StudentID, uint _CourseID) onlyManager public
    view returns(uint CourseID, uint[] TestGrade, uint CourseGrade, LearningProgress Lp) {
        Stu_Course storage sci = students[_StudentID].stu_courses[_CourseID];
        uint[] memory result = sci.TestGrade;
        CourseID = sci.CourseID;
        TestGrade = result;
        CourseGrade = sci.CourseGrade;
        Lp = sci.Lp;
    }
    
    function get_Course(uint _CourseID) onlyManager public
    view returns(uint CourseID, string CourseName, bool Compulsory, uint Term, uint Credit, uint[] Percentage, uint[] cStuIDs) {
        Course storage ci = courses[_CourseID];
        uint[] memory a = ci.Percentage;
        uint[] memory b = ci.cStuIDs;
        CourseID = ci.CourseID;
        CourseName = ci.CourseName;
        Compulsory = ci.Compulsory;
        Term = ci.Term;
        Credit = ci.Credit;
        Percentage = a;
        cStuIDs = b;
    }
    
    function get_Teacher(uint _TeacherID) onlyManager public
    view returns(uint TeacherID, string TeacherName, address TeacherAddr, uint[] tCourseIDs) {
        Teacher storage ti = teachers[_TeacherID];
        uint[] memory a = ti.tCourseIDs;
        TeacherID = ti.TeacherID;
        TeacherName = ti.TeacherName;
        TeacherAddr = ti.TeacherAddr;
        tCourseIDs = a;
    }
    
    function get_Manager(uint _ManagerID) onlyManager public
    view returns(uint ManagerID, address ManagerAddr) {
        Manager storage mi = managers[_ManagerID];
        ManagerID = mi.ManagerID;
        ManagerAddr = mi.ManagerAddr;
    }


/* currently not used debug function */
/*
    function get_cStuIDs(uint _CourseID) public view returns(uint[]) {
        uint[] memory result = courses[_CourseID].cStuIDs;
        return result;
    }
    
    function get_cPercentage(uint _CourseID) public view returns(uint[]) {
        uint[] memory result = courses[_CourseID].Percentage;
        return result;
    }
    
    function get_scTestGrade(uint _StudentID, uint _CourseID) public view returns(uint[]) {
        uint[] memory result = students[_StudentID].stu_courses[_CourseID].TestGrade;
        return result;
    }

    function get_sCourseIDs(uint _StudentID) public view returns(uint[]) {
        uint[] memory result = students[_StudentID].sCourseIDs;
        return result;
    }
*/




    // set the address of SuperUser contract
    
    event SetSuperUser(address newSuperUser);
    
    function setSuperUser (address _SuperUser) onlyOwner public returns(bool) {
        SuperUser = _SuperUser;
        emit SetSuperUser(_SuperUser);
        return true;
    }
    
    uint8 private safeNumberForOwner = 0;
    
    event TransferOwnerShip(address newOwner);
    
    function transferOwnerShip(address _newOwner) onlyOwner public returns(bool) {
        //Have to call this func for 3 times to change Owner.
        if (safeNumberForOwner < 3) {
            safeNumberForOwner += 1;
            return false;
        }
        else {
            Owner = _newOwner;
            safeNumberForOwner = 0;
            emit TransferOwnerShip(_newOwner);
            return true;
        }
    }
    
    function get_safeNumberForOwner() onlyOwner public view returns(uint8) {
        return safeNumberForOwner;
    }
    
    /*
    event SetOwner(address newOwner);
    
    function setOwner(address _newOwner) onlySuperUser public returns(bool) {
        Owner = _newOwner;
        SetOwner(_newOwner);
        return true;
    }
    */
    
    event SetLogAddress(address newLogContract);
    
    function setLogAddress(address _LogContract) onlyOwner public returns(bool) {
        LogContract = _LogContract;
        log = StudyLog(_LogContract);
        emit SetLogAddress(_LogContract);
        return true;
    }


/* Modifiers */

    modifier onlyOwner {
        if (msg.sender != Owner) revert();
        _;
    }

    modifier onlySuperUser {
        if (msg.sender != SuperUser) revert();
        _;
    }

    modifier onlyManager {
        if (msg.sender != SuperUser) {
            if (managerTag[msg.sender] != true) revert();
        }
        _;
    }
    
    modifier onlyManagerAbove {
        if (managerTag[msg.sender] != true && msg.sender != SuperUser && msg.sender != Owner) revert();
        _;
    }
    
    modifier onlyStudent {
        if (msg.sender != SuperUser) {
            if (studentTag[msg.sender] != true) revert();
        }
        _;
    }
    
    modifier onlyTeacher {
        if (msg.sender != SuperUser) {
            if (teacherTag[msg.sender] != true) revert();
        }
        _;
    }
    
    modifier onlyCourseTeacher (uint _TeacherID, uint _CourseID) {
        if (msg.sender != SuperUser) {
            if (!(teachers[_TeacherID].tCourseIDsTag[_CourseID] && msg.sender == teachers[_TeacherID].TeacherAddr)) revert();
        }
        _;
    }
    
    modifier onlySelfStudent (uint _StudentID) {
        if (msg.sender != SuperUser) {
            if (studentTag[msg.sender] != true || students[_StudentID].StudentAddr != msg.sender)
                revert();
        }
        _;
    }
    
    modifier onlyUser {
        if (msg.sender != SuperUser) {
            if (studentTag[msg.sender] != true && managerTag[msg.sender] != true && teacherTag[msg.sender] != true)
                revert();
        }
        _;
    }
    
    modifier only_M_CT_SS (uint _ID, uint _CourseID) {
        if (msg.sender != SuperUser) {
            bool Authenticated = false;
            // msg.sender is Course Teacher?
            if (teachers[_ID].tCourseIDsTag[_CourseID] && msg.sender == teachers[_ID].TeacherAddr)
                Authenticated = true;
            // msg.sender is Self Student?
            if (studentTag[msg.sender] == true && students[_ID].StudentAddr == msg.sender)
                Authenticated = true;
            // msg.sender is Manager?
            if (managerTag[msg.sender] == true)
                Authenticated = true;
            //Final check.
            if (!Authenticated) revert();
        }
        _;
    }
    
    modifier only_M_CT (uint _ID, uint _CourseID) {
        if (msg.sender != SuperUser) {
            bool Authenticated = false;
            // msg.sender is Course Teacher?
            if (teachers[_ID].tCourseIDsTag[_CourseID] && msg.sender == teachers[_ID].TeacherAddr)
                Authenticated = true;
            // msg.sender is Manager?
            if (managerTag[msg.sender] == true)
                Authenticated = true;
            //Final check.
            if (!Authenticated) revert();
        }
        _;
    }
    
    modifier only_M_T_SS (uint _ID) {
        if (msg.sender != SuperUser) {
            if (!(studentTag[msg.sender] == true && students[_ID].StudentAddr == msg.sender) && managerTag[msg.sender] != true && teacherTag[msg.sender] != true)
                revert();
        }
        _;
    }
    
    modifier only_M_T () {
        if (msg.sender != SuperUser) {
            if (managerTag[msg.sender] != true && teacherTag[msg.sender] != true)
                revert();
        }
        _;
    }

/* Functions */

    /*
    
    //Currently not used because of gas overused.
    
    // check whether the manager address or the managerID is exist or not
    function managerAddrExist (address _ManagerAddr) public view returns (bool) {
        for (uint m = 0; m < ManagerList.length; m++) {
            if(managers[ManagerList[m]].ManagerAddr == _ManagerAddr) {
                return true;
            }
        }
        return false;
    }

    // check whether the student address is exist or not
    function studentAddrExist (address _StudentAddr) public view returns (bool) {
        for (uint s = 0; s < StudentList.length; s++) {
            if (students[StudentList[s]].StudentAddr == _StudentAddr) {
                return true;
            }
        }
        return false;
    }

    // check whether the managerID is exist or not
    function managerIDExist (uint _ManagerID) public view returns (bool) {
        for (uint c = 0; c < ManagerList.length; c++) {
            if(ManagerList[c] == _ManagerID)
            return true;
        }
        return false;
    }

    // check whether the StudentID is exist or not
    function studentIDExist (uint _StudentID) public view returns (bool) {
        for (uint s = 0; s < StudentList.length; s++) {
            if (StudentList[s] == _StudentID) {
                return true;
            }
        }
        return false;
    }

    // check whether the courseID is exist or not
    function courseIDExist (uint _CourseID) public view returns (bool) {
        for (uint c = 0; c < CourseList.length; c++) {
            if(CourseList[c] == _CourseID)
            return true;
        }
        return false;
    }
    
    // check whether the teacherID is exist or not
    function teacherIDExist (uint _TeacherID) public view returns (bool) {
        for (uint c = 0; c < TeacherList.length; c++) {
            if(TeacherList[c] == _TeacherID)
            return true;
        }
        return false;
    }
    
    */
    
    
/* Add Info functions */

    //event TxMined(string indexed txid, bool indexed Success, address indexed Operator);
    
    mapping (string => bool) private TxTag;
    
    bool private enableTxTag = true;
    
    function setTxTag(string _Txid, bool value) internal {
        if (enableTxTag) {
            TxTag[_Txid] = value;
        }
    }
    
    function getTxTag(string _Txid) public view returns (bool) {
        if (enableTxTag) {
            return TxTag[_Txid];
        }
    }
    
    function setEnableTxTag(bool value) onlySuperUser public {
        enableTxTag = value;
    }
    
    function getEnableTxTag() public view returns (bool) {
        return enableTxTag;
    }


    //set student ID and other info, push student ID into StudentList
    
    function addStuInfo (string _Txid, uint _StudentID, uint _StudentClass)
    onlyManager public returns(bool) {
        stu_tmp.StudentID = _StudentID;
        stu_tmp.StudentName = "StudentName";  //stu_tmp.StudentName = _StudentName;
        stu_tmp.StudentClass = _StudentClass;
        students[_StudentID] = stu_tmp;
        if (!studentIDTag[_StudentID]) {
            studentIDTag[_StudentID] = true;
            StudentList.push(_StudentID);
            class_stu[_StudentClass].push(_StudentID);
        }
        setTxTag(_Txid, true);
        log.addStuInfo(_Txid, true, msg.sender, _StudentID, "StudentName", _StudentClass);
        return true;
    }
    Student private stu_tmp;
    
    //set teacher ID and other info, push teacher ID into TeacherList
    
    function addTchInfo (string _Txid, uint _TeacherID) onlyManager public returns(bool) {
        tch_tmp.TeacherID = _TeacherID;
        tch_tmp.TeacherName = "TeacherName";  //tch_tmp.TeacherName = _TeacherName;
        teachers[_TeacherID] = tch_tmp;
        if (!teacherIDTag[_TeacherID]) {
            teacherIDTag[_TeacherID] = true;
            TeacherList.push(_TeacherID);
        }
        setTxTag(_Txid, true);
        log.addTeacherInfo(_Txid, true, msg.sender, _TeacherID, "TeacherName");
        return true;
    }
    Teacher private tch_tmp;
    
    //set course basic info.
    
    function addCourseInfo (string _Txid, uint _CourseID, bool _Compulsory, uint _Term, uint _Credit, uint[] _Percentage, uint _TeacherID)
    onlyManager public returns(bool) {
        course_tmp.CourseID = _CourseID;
        course_tmp.CourseName = "CourseName";  //course_tmp.CourseName = _CourseName;
        course_tmp.Compulsory = _Compulsory;
        course_tmp.Term = _Term;
        course_tmp.Credit = _Credit;
        course_tmp.Percentage = _Percentage;
        courses[_CourseID] = course_tmp;
        if (!courseIDTag[_CourseID]) {
            courseIDTag[_CourseID] = true;
            CourseList.push(_CourseID);
        }
        if (!teachers[_TeacherID].tCourseIDsTag[_CourseID]) {
            teachers[_TeacherID].tCourseIDsTag[_CourseID] = true;
            teachers[_TeacherID].tCourseIDs.push(_CourseID);
        }
        setTxTag(_Txid, true);
        log.addCourseInfo(_Txid, true, msg.sender, _CourseID, "CourseName", _Compulsory, _Term, _Credit, _Percentage, _TeacherID);
        return true;
    }
    Course private course_tmp;
    
    //set manager ID and other info, push manager ID into ManagerList
    
    function addManagerInfo (string _Txid, uint _ManagerID) onlySuperUser public returns(bool) {
        manager_tmp.ManagerID = _ManagerID;
        managers[_ManagerID] = manager_tmp;
        if (!managerIDTag[_ManagerID]) {
            managerIDTag[_ManagerID] = true;
            ManagerList.push(_ManagerID);
        }
        setTxTag(_Txid, true);
        log.addManagerInfo(_Txid, true, msg.sender, _ManagerID);
        return true;
    }
    Manager private manager_tmp;
    
    
    
/* Set address to registered account */
    // set manager's address, manager info should have been exist.
    function AddStudentAddr (uint _StudentID, address _StudentAddress)
    onlyManager internal returns (bool) {
        students[_StudentID].StudentAddr = _StudentAddress;
        studentTag[_StudentAddress] = true;
        return true;
    }

    function AddTeacherAddr (uint _TeacherID, address _TeacherAddress)
    onlyManager internal returns (bool) {
        teachers[_TeacherID].TeacherAddr = _TeacherAddress;
        teacherTag[_TeacherAddress] = true;
        return true;
    }
    
    function AddManagerAddr (uint _ManagerID, address _ManagerAddress)
    onlySuperUser internal returns (bool) {
        managers[_ManagerID].ManagerAddr = _ManagerAddress;
        managerTag[_ManagerAddress] = true;
        return true;
    }
    
/* After register, user generate a eth address, and record the addresss */

    function addAccount (string _Txid, uint _Identity, uint _ID, address _Addr) onlyManagerAbove public returns(bool) {
        bool success = false;
        if (_Identity == 0) {
            //Students
            success = AddStudentAddr(_ID, _Addr);
        } else if (_Identity == 1) {
            //Teachers
            success = AddTeacherAddr(_ID, _Addr);
        } else if (_Identity == 2) {
            //Managers
            success = AddManagerAddr(_ID, _Addr);
        }
        log.addAccount(_Txid, true, msg.sender, _Identity, _ID, _Addr);
        setTxTag(_Txid, true);
        return success;
    }


    //Calculate student mark.
    function CalcMark(uint _CourseID, uint _StudentID) internal returns(uint mark) {
        uint[] memory grades = students[_StudentID].stu_courses[_CourseID].TestGrade;
        uint[] memory percents = courses[_CourseID].Percentage;
        uint gradeSum;
        uint percentSum;
        if (grades.length != percents.length) revert();
        for (uint i = 0; i < grades.length; i++) {
            gradeSum += grades[i] * percents[i];
            percentSum += percents[i];
        }
        mark = gradeSum / percentSum;
        students[_StudentID].stu_courses[_CourseID].CourseGrade = mark;
    }
    
    //Teacher set the mark of one student.
    
    function setStuMark(string _Txid, uint _TeacherID, uint _CourseID, uint _StudentID, uint[] _Marks)
    only_M_T public returns(bool boolValue, uint mark){
        boolValue = true;
        for (uint i = 0; i < students[_StudentID].sCourseIDs.length; i++) {
            if (_CourseID == students[_StudentID].sCourseIDs[i]) {
                students[_StudentID].stu_courses[_CourseID].TestGrade = _Marks;
                mark = CalcMark(_CourseID, _StudentID);
                setTxTag(_Txid, boolValue);
                log.setStuMark(_Txid, boolValue, msg.sender, _TeacherID, _CourseID, _StudentID, _Marks);
                return (boolValue, mark);
            }
        }
        //Fail. Stu doesn't take this course.
        boolValue = false;
        setTxTag(_Txid, false);
        log.setStuMark(_Txid, boolValue, msg.sender, _TeacherID, _CourseID, _StudentID, _Marks);
        return (boolValue, 0);
    }



    //How many classes has a student choose.
    function len_sCourseIDs (uint _StudentID) only_M_T_SS(_StudentID) public view returns(uint) {
        return students[_StudentID].sCourseIDs.length;
    }
    
    //How many students a course has.
    function len_cStuIDs (uint _CourseID) onlyUser public view returns(uint) {
        return courses[_CourseID].cStuIDs.length;
    }
    
    //Student choose Course.
    
    function stuChooseCourse(string _Txid, uint _CourseID, uint _StudentID, uint _requestTime)
    onlySelfStudent(_StudentID) public returns(bool) {
        if (!courses[_CourseID].cStuIDsTag[_StudentID]) {
            courses[_CourseID].cStuIDsTag[_StudentID] = true;
            courses[_CourseID].cStuIDs.push(_StudentID);
            students[_StudentID].sCourseIDs.push(_CourseID);
            students[_StudentID].stu_courses[_CourseID].CourseID = _CourseID;
            students[_StudentID].stu_courses[_CourseID].Lp = LearningProgress.Start;
        }
        setTxTag(_Txid, true);
        log.stuChooseCourse(_Txid, true, msg.sender, _CourseID, _StudentID, _requestTime);
        return true;
    }
    

    // return one course Mark of a student.
    function getStuMark (uint _StudentID, uint _CourseID)
    only_M_T_SS(_StudentID) public view returns(uint) {
        return students[_StudentID].stu_courses[_CourseID].CourseGrade;
    }
    

/* This func was commented in 2018.03.20, to save gas consumption.

    function getStuMarks5 (uint _StudentID, uint _Page)
    only_M_T_SS(_StudentID) public view returns (uint[5] Terms, bool[5] Compulsorys, uint[5] Credits, uint[5] Marks) {
        uint len = len_sCourseIDs(_StudentID);  //Number of courses that student takes.
        uint _NumOfLables = 5;
        uint endpoint;  //return how many data.
        uint i = 0;
        uint j = 0;
        if (len/_NumOfLables < _Page) {
            if (len/_NumOfLables + 1 == _Page && _Page != 0) {
                endpoint = len;
            } else {
                revert();
            }
        } else {
            endpoint = _Page*_NumOfLables;
        }
        for (i = _NumOfLables*(_Page-1); i < endpoint; i++) {
            //make a Stu_Course instance, name as sci.
            Stu_Course storage sci = students[_StudentID].stu_courses[i];
            Course storage ci = courses[sci.CourseID];
            (Terms[j],Compulsorys[j],Credits[j],Marks[j]) = (ci.Term,ci.Compulsory,ci.Credit,sci.CourseGrade);
            j++;
        }
        return;
    }
*/
    
    function getStuMarksByCourse (uint _CourseID, uint _StudentID)
    only_M_T_SS(_StudentID) public view returns(uint) {
        return students[_StudentID].stu_courses[_CourseID].CourseGrade;
    }
    
    
    function getStuMarksByCourseAll (uint _CourseID)
    only_M_T public view returns (uint[], uint[]) {
        //uint len = courses[_CourseID].cStuIDs.length;
        uint[] memory StuIDs = courses[_CourseID].cStuIDs;
        uint[] memory Marks = courses[_CourseID].cStuIDs; //仅用此语句分配空间
        for (uint i = 0; i < courses[_CourseID].cStuIDs.length; i++) {
            Marks[i] = students[StuIDs[i]].stu_courses[_CourseID].CourseGrade;
        }
        return (StuIDs, Marks);
    }
    
    
    /*
    function addStuEvaluation(string _fileHash, uint _StudentID)
    onlyManager public returns(uint newLength) {
        stuEvaluations[_StudentID].push(_fileHash);
        return stuEvaluations[_StudentID].length;
    }
    
    
    function getStuEvaluation(uint _StudentID, uint index)
    onlyManager public view returns(string fileHash) {
        return stuEvaluations[_StudentID][index];
    }
    
    
    function addStuRPFile(string _fileHash, uint _StudentID)
    onlyManager public returns(uint newLength) {
        stuRPFiles[_StudentID].push(_fileHash);
        return stuRPFiles[_StudentID].length;
    }
    
    
    function getStuRPFile(uint _StudentID, uint index)
    onlyManager public view returns(string fileHash) {
        return  stuRPFiles[_StudentID][index];
    }
    */
    
    
    /*
    
    // Query functions for visitors.
    
    modifier only_M_SS (uint _ID) {
        if (msg.sender != SuperUser) {
            if (!(studentTag[msg.sender] == true && students[_ID].StudentAddr == msg.sender) && managerTag[msg.sender] != true)
                revert();
        }
        _;
    }
    
    
    mapping(bytes32 => bool) VisitorAuthorityTag;
    
    
    event ReqMarkQuery(uint StudentID, address Visitor);
    
    
    function reqMarkQuery(uint _StudentID) public {
        ReqMarkQuery(_StudentID, msg.sender);
    }
    
    
    event ApproveMarkQuery(bool isApproved, uint Student, address Visitor);
    
    
    function approveMarkQuery(bool _isApproved, uint _StudentID, address _Visitor)
    only_M_SS(_StudentID) public {
        VisitorAuthorityTag[keccak256(_StudentID, keccak256(_Visitor), _Visitor)] = _isApproved;
        ApproveMarkQuery(_isApproved, _StudentID, _Visitor);
    }
    
    
    function visitorMarkQueryByCourse(uint _StudentID, uint _CourseID) public view returns (bool isApproved, uint Mark) {
        isApproved = VisitorAuthorityTag[keccak256(_StudentID, keccak256(msg.sender), msg.sender)];
        if (isApproved) {
            Mark = students[_StudentID].stu_courses[_CourseID].CourseGrade;
            return;
        }
        return;
    }
    
    
    function visitorMarkQueryAll(uint _StudentID)
    public view returns (bool isApproved, uint[] CourseIDs, uint[] Marks) {
        isApproved = VisitorAuthorityTag[keccak256(_StudentID, keccak256(msg.sender), msg.sender)];
        if (isApproved) {
            Student storage si = students[_StudentID];
            uint[] memory a = si.sCourseIDs;
            uint[] memory b = new uint[](a.length);
            for (uint i = 0; i < a.length ; i++) {
                b[i] = si.stu_courses[a[i]].CourseGrade;
            }
            CourseIDs = a;
            Marks = b;
            return;
        }
        return;
    }
    */
    
    
}