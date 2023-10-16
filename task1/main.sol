// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract StudentFactory {

    struct Student {
        string name;
        uint8 age;
    }

    enum EducationDegree {
        Bachelor,
        Master,
        PHD
    }

    struct Group {
        EducationDegree educationDegree;
        uint number;
        Student[] students;
    }

    Student[] public students;
    Group[] public groups;

    function getGroupStudents(uint groupIdx) public view returns (Student[] memory) {
        return groups[groupIdx].students;
    }

    function _addGroup(Group memory newGroup) private {
        Group storage group = groups.push();
        group.educationDegree = newGroup.educationDegree;
        group.number = newGroup.number;

        for (uint i = 0; i < newGroup.students.length; i++) {
            group.students.push(newGroup.students[i]);
        }
    }

    constructor() {

        Student memory Andrey = Student("Andrey", 22);
        Student memory Vasya = Student("Vasya", 42);
        Student memory Petya = Student("Petya", 33);

        students.push(Andrey);
        students.push(Vasya);
        students.push(Petya);

        Group memory groupBachelor = Group({
            educationDegree: EducationDegree.Bachelor,
            number: 912,
            students: new Student[](2)
        });
        groupBachelor.students[0] = Andrey;
        groupBachelor.students[1] = Vasya;

        Group memory groupMaster = Group({
            educationDegree: EducationDegree.Master,
            number: 316,
            students: new Student[](1)
        });
        groupMaster.students[0] = Petya;

        _addGroup(groupBachelor);
        _addGroup(groupMaster);
    }



    function _getRandomGroup() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % groups.length;
    }

    function _addStudent(string memory _name, uint8 _age) private {
        students.push(Student(
            _name,
            _age
        ));
    }

    function addGroup(EducationDegree _educationDegree, uint _number) public {
        _addGroup(Group(_educationDegree, _number, new Student[](0)));
    }

    function addStudentToRandomGroup(string memory _name, uint8 _age) public {
        _addStudent(_name, _age);

        uint randGroupIdx = _getRandomGroup();
        groups[randGroupIdx].students.push(Student(_name, _age));
    }

}