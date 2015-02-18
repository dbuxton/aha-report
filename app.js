// Generated by CoffeeScript 1.9.0
(function() {
  var context;

  context = {
    authenticated: false,
    loading: false,
    doneFeatures: [],
    notDoneFeatures: [],
    users: []
  };

  $(function() {
    var source, template, userTemplate;
    source = $('#template').html();
    template = Handlebars.compile(source);
    $('#template').html(template(context));
    source = $('#user-template').html();
    userTemplate = Handlebars.compile(source);
    $('#user-template').html(userTemplate(context));
    return $('#load-aha').click(function() {
      context.loading = true;
      $('#template').html(template(context));
      return new AhaApi({
        accountDomain: $('#subdomain').val(),
        clientId: '10218890e8290548ea28cc16d4bbb4e705bcf4f45a4a6cb8632d31cd27b51c78',
        redirectUri: "https://dbuxton.github.io/aha-report/"
      }).authenticate(function(api, success, message) {
        var productKey;
        productKey = "APP";
        context.authenticated = true;
        $('#template').html(template(context));
        return api.get("/products/APP/users", {}, function(response) {
          var u, _i, _len, _ref;
          _ref = response.project_users;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            u = _ref[_i];
            context.users.push(u.user);
          }
          $('#user-template').html(userTemplate(context));
          context.loading = false;
          return api.get("/products/APP/features", {
            per_page: 300,
            updated_since: Date.today().previous().saturday()
          }, function(response) {
            var feature, featuresHash, _j, _len1, _ref1;
            featuresHash = {};
            $('#template').html(template(context));
            _ref1 = response.features;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              feature = _ref1[_j];
              api.get("/features/" + feature.reference_num, {}, function(response) {
                if (response.feature.assigned_to_user) {
                  if (!featuresHash[response.feature.assigned_to_user.id]) {
                    featuresHash[response.feature.assigned_to_user.id] = [];
                  }
                  return featuresHash[response.feature.assigned_to_user.id].push(response.feature);
                }
              });
            }
            return $('#user-select').change(function() {
              var doneFeatures, notDoneFeatures, userFeatures, userId, _k, _len2;
              userId = $('#user-select').val();
              userFeatures = featuresHash[userId];
              doneFeatures = [];
              notDoneFeatures = [];
              if (userFeatures) {
                for (_k = 0, _len2 = userFeatures.length; _k < _len2; _k++) {
                  feature = userFeatures[_k];
                  if (feature.workflow_status.name === "Complete" || feature.workflow_status.name === "On production") {
                    doneFeatures.push(feature);
                  } else {
                    notDoneFeatures.push(feature);
                  }
                }
              }
              context.notDoneFeatures = notDoneFeatures;
              context.doneFeatures = doneFeatures;
              return $('#template').html(template(context));
            });
          });
        });
      });
    });
  });

}).call(this);
