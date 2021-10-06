const mdtApp = new Vue({
    el: "#container",
    data: {
        page: "NotesTest",
        search_person: "",
        searched_persons: {
            query: "",
            results: false
        },
        alertLevel0: '#0b151e',
        alertLevel1: 'green',
        alertLevel2: 'orange',
        alertLevel3: 'red',

        search_vehicle: "",
        searched_vehicles: {
            identifier: "",
            firstname: "",
            lastname: "",
            vehicleModel: ""
        },

        selected_person: {
            result: false,
            identifier: "",
            fines: "",
            mugshot_url: "",
            licenses: "",
            notes: "",
            firstname: null,
            lastname: null,
            dateofbirth: null,
            sex: null,
            height: null,
            job: null
        },

        all_fines: "",

        new_note: "",
        create_note: false,
    },
    methods: {
        SearchPerson() {
            if (this.search_person) {
                this.searched_persons.query = this.search_person;
                $.post('https://duckymdt/searchperson', JSON.stringify({
                    query: this.search_person
                }));

                this.searched_persons.results = false;
                return;
            }
        },
        SearchVehicle() {
            if (this.search_vehicle) {

                $.post('https://duckymdt/searchvehicle', JSON.stringify({
                    query: this.search_vehicle
                }));

                this.searched_vehicles.result = false
                return;
            }
        },
        SearchProfile(identifier) {
            $.post('https://duckymdt/persondatasheet', JSON.stringify({
                identifier: identifier
            }));
            this.selected_person.identifier = identifier;
            return;                
        },
        ChangeImage(identifier) {
            display(false)
            $.post('https://duckymdt/changeimage', JSON.stringify({
                identifier: identifier
            }));
            return;
        },
        ChangeRiskiness(identifier, newRiskiness) {
            $.post('https://duckymdt/changeriskiness', JSON.stringify({
                identifier: identifier,
                newRiskiness: newRiskiness
            }));
            return;
        },
        RemoveLicence(identifier, licence) {
            $.post('https://duckymdt/removelicence', JSON.stringify({
                identifier: identifier,
                licence: licence
            }))
            return;
        },
        RemoveFine(fine) {
            $.post('https://duckymdt/removefine', JSON.stringify({
                fine: fine
            }));
            return;
        },
        OpenCollapsible() {
            var content = document.getElementsByClassName("riskinessbuttoncontent");
            if ($("riskinessbuttoncontent").css("display", "none") === "block") {
            content.style.display = "none";
            } else {
            content.style.display = "block";
            }
        },
        RequestAllFines() {
            $.post('https://duckymdt/requestallfines', JSON.stringify({}));
            return;
        },
        AddFine(identifier, name, fine) {
            $.post('https://duckymdt/addfine', JSON.stringify({
                identifier: identifier,
                name: name,
                fine: fine
            }))
            return;
        },
        RequestNotes(identifier) {
            $.post('https://duckymdt/requestnotes', JSON.stringify({
                identifier: identifier
            }))
            return;
        },
        RemoveNote(note) {
            $.post('https://duckymdt/removenote', JSON.stringify({
                note: note
            }))
            return;
        },
        CreateNote(identifier, firstname, lastname) {
            if (this.new_note != '') {
                $.post('https://duckymdt/createnote', JSON.stringify({
                    identifier: identifier,
                    firstname: firstname,
                    lastname: lastname,
                    note: this.new_note,
                }))
            }
            return;
        },
        ChangePage(page) {
            this.page = page
        },
        ClearForm(){
            this.search_person = "";
            this.search_vehicle = "";
            this.new_note = "";
        },
        Filter(){
            var value = $("#filterfines").val().toLowerCase();
            $("#availablefines tr").filter(function() {
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
            });
        }
    },
})

display(false)

function display(bool) {
    if (bool) {
        $("#container").show();
    } else {
        $("#container").hide();
    }
}

function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
      if ((new Date().getTime() - start) > milliseconds){
        break;
      }
    }
}

document.onkeyup = function(data) {
    if (data.key == 'Escape') {
        $.post('https://duckymdt/exit', JSON.stringify({}));
        return;
    }
};


window.addEventListener('message', function(event) {
    var item = event.data;
    if (item.type === "nui") {
        if (item.status == true) {
            display(true)
            mdtApp.ChangePage('Home')
        } else {
            display(false)
        }
    } else if (item.type === "returnedPersonMatches") {
        mdtApp.searched_persons.results = item.matches;
        mdtApp.ChangePage('SearchPerson');
    } else if (item.type === "returnedPersonVehicles") {
        mdtApp.searched_vehicles.identifier = item.identifier;
        mdtApp.searched_vehicles.firstname = item.firstname;
        mdtApp.searched_vehicles.lastname = item.lastname;
        mdtApp.searched_vehicles.vehicleModel = item.vehicleModel;
        mdtApp.ChangePage('SearchVehicle');
    } else if (item.type === "returnedSearchPersonDatasheet") {
        mdtApp.selected_person.result = item.result;
        mdtApp.selected_person.fines = item.fines;
        mdtApp.selected_person.vehicleList = item.vehicleList
        mdtApp.selected_person.licenses = item.licenses
        mdtApp.ChangePage('PersonDataSheet');
    } else if (item.type === "updatedMugshotImage") {
        mdtApp.selected_person.result.mugshot_url = item.url
        display(true)
        sleep(1000);
        mdtApp.SearchProfile(mdtApp.selected_person.identifier)
    } else if (item.type === "removedFine") {
        sleep(2000);
        mdtApp.SearchProfile(mdtApp.selected_person.identifier)
    } else if (item.type === "changedRiskiness") {
        sleep(2000);
        mdtApp.SearchProfile(mdtApp.selected_person.identifier)
    } else if (item.type === "removedLicence") {
        sleep(2000);
        mdtApp.SearchProfile(mdtApp.selected_person.identifier)
    } else if (item.type === "returnAllFines") {
        mdtApp.all_fines = item.fines
        mdtApp.ChangePage('Fines');
    } else if (item.type === 'returnedNotesofPerson') {
        mdtApp.selected_person.notes = item.notes
        mdtApp.ChangePage('Notes');
    } else if (item.type === 'removedNote') {
        sleep(2000);
        mdtApp.RequestNotes(mdtApp.selected_person.identifier);
    } else if (item.type === 'addedNote') {
        sleep(2000);
        mdtApp.RequestNotes(mdtApp.selected_person.identifier);
    }
})