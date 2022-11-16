#include <iostream>
#include <cstdlib>
#include "CourseWithEqualsOperatorOverloaded.h"
using namespace std;

Course::Course(const string &courseName, int capacity)
{
  numberOfStudents = 0;
  this->courseName = courseName;
  this->capacity = capacity;
  students = new string[capacity];
}

Course::~Course()
{
  delete [] students;
}

string Course::getCourseName() const
{
  return courseName;
}

void Course::addStudent(const string &name)
{
  if (numberOfStudents >= capacity)
  {
    cout << "The maximum size of array exceeded" << endl;
    cout << "Program terminates now" << endl;
    exit(0);
  }

  students[numberOfStudents] = name;
  numberOfStudents++;
}

void Course::dropStudent(const string &name)
{
  // Left as an exercise
}

string* Course::getStudents() const
{
  return students;
}

int Course::getNumberOfStudents() const
{
  return numberOfStudents;
}

Course::Course(Course& course) // Copy constructor
{
  courseName = course.courseName;
  numberOfStudents = course.numberOfStudents;
  capacity = course.capacity;
  students = new string[capacity];
}

const Course& Course::operator=(const Course& course)
{
  if (this != &course) // Do nothing with self-assignment
  {
    courseName = course.courseName;
    numberOfStudents = course.numberOfStudents;
    capacity = course.capacity;

    delete [] this->students; // Delete the old array

    // Create a new array with the same capacity as course copied
    students = new string[capacity]; 
    for (int i = 0; i < numberOfStudents; i++)
      students[i] = course.students[i];
  }

  return *this;
}

