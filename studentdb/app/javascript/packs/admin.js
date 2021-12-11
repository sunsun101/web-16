// function dismiss(id) {
//   console.log(id);
// }

// var users = httpGet(user_registration_path(id));
// console.log(users);

// var setUsersCallback = function httpGet(theUrl) {
//   var xmlHttp = new XMLHttpRequest();
//   xmlHttp.open("GET", theUrl, false);
//   xmlHttp.send(null);
//   return xmlHttp.responseText;
// };
// document.addEventListener("turbolinks:load", () => {
//   setUsersCallback("/users");
// });

// document.addEventListener("turbolinks:render", () => {
//   setUsersCallback();
// });
// function processData(data) {
//   console.log(data);
//   console.log(JSON.parse(data).length);
// }
function delete_user(id) {
  console.log("Id ===>", id);
  // var params = JSON.stringify({ id: id });
  // $.get("/users/destroy", params, function (data) {});
  $.ajax({
    url: "/users/destroy?id=" + id,
    type: "DELETE",
    success: function (result) {
      // Do something with the result
    },
  });
}

function setUsersCallback() {
  // var params = '{"field1": "value1", "field2: "value2"}';
  $.get("/site/users", function (data) {
    let parsed_data = JSON.parse(data);
    let table_body = document.getElementById("table_body");
    const fields = { 0: "email", 1: "is_admin" };
    parsed_data.forEach((element) => {
      var tr = document.createElement("tr");

      for (var j = 0; j < 3; j++) {
        // if (i == 2 && j == 1) {
        //   break;
        // } else {
        var td = document.createElement("td");
        if (j == 2) {
          var edit_button = document.createElement("input");
          edit_button.type = "button";
          edit_button.className = "btn btn-primary";
          edit_button.value = "Edit";
          edit_button.setAttribute("data-mdb-target", "#editModal");
          edit_button.setAttribute("data-mdb-toggle", "modal");
          edit_button.setAttribute("id", "myModal_" + element.id);
          edit_button.onclick = (function () {
            return function () {
              $("#email").val(element.email);
              $("#is_admin").prop("checked", element.is_admin ? true : false);
              $("#user_id").val(element.id);
            };
          })();
          var delete_button = document.createElement("input");
          delete_button.type = "button";
          delete_button.className = "btn btn-danger";
          delete_button.value = "Delete";
          delete_button.onclick = (function () {
            return function () {
              delete_user(element.id);
            };
          })();
          td.appendChild(edit_button);
          td.appendChild(delete_button);
        } else {
          td.innerText = element[fields[j]];

          // i == 1 && j == 1 ? td.setAttribute("rowSpan", "2") : null;
        }

        tr.appendChild(td);
      }
      // }
      table_body.appendChild(tr);
    });
  });
}

document.addEventListener("turbolinks:load", () => {
  console.log("dilanka");
  setUsersCallback();
});

document.addEventListener("turbolinks:render", () => {
  console.log("something");
  // setUsersCallback();
});
