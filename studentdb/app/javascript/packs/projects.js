
// import SelectPure from "@jaycverg/select-pure";
import SlimSelect from 'slim-select';

var setStudentSelector = function () {
  var element = document.querySelector('#existing-students');
  if (element && !element.slim) {
    new SlimSelect({
      select: element,
      placeholder: 'Add existing students',
    });
  }
  element = document.querySelector('#existing-projects');
  if (element && !element.slim) {
    new SlimSelect({
      select: element,
      placeholder: 'Add existing projects',
    });
  }
}

var setProjectCallbacks = function () {
  document.querySelectorAll('.destroy-student-link').forEach((el) => {
    const index = el.dataset.studentIndex;
    el.onclick = function () {
      document.querySelector('#project_students_attributes_' + index + '__destroy').checked = true;
      document.querySelector('#student-' + index + '-form').style.display = 'none';
      return false;
    }
  });
  document.querySelectorAll('.recursive-destroy-student-link').forEach((el) => {
    const index = el.dataset.studentIndex;
    el.onclick = function () {
      document.querySelector('#project_students_attributes_' + index + '__destroy_r').checked = true;
      document.querySelector('#student-' + index + '-form').style.display = 'none';
      return false;
    }
  });
  document.querySelectorAll('.destroy-project-link').forEach((el) => {
    const index = el.dataset.projectIndex;
    el.onclick = function () {
      document.querySelector('#student_projects_attributes_' + index + '__destroy').checked = true;
      document.querySelector('#project-' + index + '-form').style.display = 'none';
      return false;
    }
  });
  setStudentSelector();
}

document.addEventListener('turbolinks:load', () => {
  setProjectCallbacks();
});

document.addEventListener('turbolinks:render', () => {
  setProjectCallbacks();
});
