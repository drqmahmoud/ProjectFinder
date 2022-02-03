const Messages = {
  initialize() {
    var message;
    $(document).on('turbolinks:load', () => {

      console.log(window.location.pathname.split("/"))
      $('#convo').ready(function (ev) {
        var d = $('#inside_convo');
        d.scrollTop(d.prop("scrollHeight"));
        clearInterval(message)

        const conversationID = window.location.pathname.split("/")[2]
        console.log(window.location.pathname.split("/"))
        if (window.location.pathname.split("/")[1] == "conversations")  message = setInterval(function () {
          
          if (window.location.pathname.split("/")[1] == "conversations") {
            $.ajax({
              method: 'GET',
              url: window.location.pathname + "/getData",
              success: function (data) {
                console.log(data)
                let arr = []
                let messArr = []
                arr = data.conversations.map((item) => {
                  let user = ""
                  let innerInfor = ""
                  let classname = ""
                  let link = ""

                  if (item.id == conversationID)
                    classname = " px-2 divide-y flex space-x-2 border-black border-2 overflow-hidden outline-none bg-gray-200 w-60"
                  else
                    classname = " px-2  divide-y  bg-white-100 border-4  overflow-hidden flex space-x-2 hover:bg-gray-200 focus:outline-none focus:bg-gray-200 w-60"

                  link = `/conversations/${item.id}/messages`

                  if (item.sender_id == data.user) user = item.reciever_name
                  else user = item.sender_name


                  if (item.body) {
                    if (item.read || item.user_id == data.user) {
                      innerInfor = `<div  > Last Message:  ${item.body}  </div>`
                    }
                    else innerInfor = `<div class ="font-bold"> Last Message:  ${item.body} </div>`
                  }
                  else innerInfor = `<div> No messages exchanged! </div>`

                  let inner = `
                <a href=${link} class="${classname}">
                <button >
                <div class=" flex flex-col items-start " style = "max-height:61px; text-overflow: ellipsis;">
                  <div class="text-2xl font-bold  " >
                    ${user}
                  </div>
                  <div class="flex text-xs space-x-1 truncate">
                    ${innerInfor}
                  </div>
                </div>
              </button>
              </a>
              `

                  return inner
                })

                messArr = data.messages.map((message) => {
                  let inner = ""
                  if (message.body) {
                    if (message.user_id == data.user) {
                      inner = `
                    <div class="flex justify-end" >
                    <div class="flex items-end space-x-2 justify-end right-0" style = "max-width:600px;">
                      <div class="bg-gray-200 px-6 py-2 p-100 rounded break-words  ">
                        ${message.body}
                      </div>
                    </div>
                  </div>
                  <div class="flex justify-end mb-2" >
                    <p class=" text-sm text-gray-500">${message.created_at}</p>
                  </div>
                  `
                    }
                    else {
                      inner = `
                    <div class="flex">
                    <div class="bg-blue-700 px-6 py-2 w-auto rounded text-white break-words" style = "max-width:800px;">
                    ${message.body}
                    </div>
                  </div>
                  <p class=" text-sm text-gray-500 mb-2">${message.created_at}</p>
                  `
                    }
                  }
                  return inner
                })
                $('#allConvos').html(arr)
                $('#inside_convo').html(messArr)
              }
            })
          }

        }, 5000);
      });



      // $('#convo').unload(function (ev) {
      //     clearInterval(messages)
      // })
    });

    $(document).on('page:beforeout', function () {
      console.log("hey")
      clearInterval(message)
    });


    $(window).bind('beforeunload', function () {
      clearInterval(message)
    });
  }

}


export default Messages