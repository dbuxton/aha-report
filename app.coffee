context = {
  authenticated: false
  loading: false
  doneFeatures: []
  notDoneFeatures: []
  users: []
}

$ ->
  if window.location.href.indexOf('localtunnel') != -1
    redirectUri = 'https://lmlqqbztpm.localtunnel.me/'
  else
    redirectUri = 'https://dbuxton.github.io/aha-report/'
  source = $('#template').html()
  template = Handlebars.compile(source)
  $('#template').html(template(context))
  source = $('#user-template').html()
  userTemplate = Handlebars.compile(source)
  $('#user-template').html(userTemplate(context))
  $('#load-aha').click () ->
    context.loading = true
    $('#template').html(template(context))
    new AhaApi {
      accountDomain: $('#subdomain').val()
      clientId: '10218890e8290548ea28cc16d4bbb4e705bcf4f45a4a6cb8632d31cd27b51c78'
      redirectUri: redirectUri
    }

    .authenticate (api, success, message) ->
      productKey = "APP"
      context.authenticated = true
      $('#template').html(template(context))
      api.get "/products/APP/users", {}, (response) ->
        for u in response.project_users
          context.users.push u.user
        $('#user-template').html(userTemplate(context))
        context.loading = false
        api.get "/products/APP/features"
        , {
          per_page: 300
          updated_since: Date.today().previous().saturday()
        }, (response) ->
          featuresHash = {}
          $('#template').html(template(context))
          for feature in response.features
            api.get "/features/#{feature.reference_num}", {}, (response) ->
              if response.feature.assigned_to_user
                if not featuresHash[response.feature.assigned_to_user.id]
                  featuresHash[response.feature.assigned_to_user.id] = []
                featuresHash[response.feature.assigned_to_user.id].push(response.feature)
          $('#user-select').change () ->
            userId = $('#user-select').val()
            userFeatures = featuresHash[userId]
            doneFeatures = []
            notDoneFeatures = []
            if userFeatures
              for feature in userFeatures
                if feature.workflow_status.name == "Complete" or
                   feature.workflow_status.name == "On production"
                  doneFeatures.push feature
                else
                  notDoneFeatures.push feature
            context.notDoneFeatures = notDoneFeatures
            context.doneFeatures = doneFeatures
            $('#template').html(template(context))
