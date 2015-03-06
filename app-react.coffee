
if window.location.href.indexOf('localtunnel') != -1
  redirectUri = 'https://lmlqqbztpm.localtunnel.me/'
else
  redirectUri = 'https://dbuxton.github.io/aha-report/'

AhaReport = React.createClass {

  doneFeatures: []
  notDoneFeatures: []

  getInitialState: () ->
    return {
      subdomain: "arachnys"
    }

  render: () ->
    if @state.featuresLoaded != @state.numFeatures
      if isNaN @state.numFeatures
        loadStatus = <div className="col-xs-12">Initialising...</div>
      else
        loadStatus = <div className="col-xs-12">Loaded feature {@state.featuresLoaded} out of {@state.numFeatures}</div>
    else
      loadStatus = <SelectUserControl
        users={@state.users}
        onUserSelect={@handleUserSelect}
      />
    return (
      <div className="row">
        <div className="col-xs-12">
          <h3>Aha report</h3>
        </div>
        <AuthenticateControl
          subdomain={@state.subdomain}
          onAuthenticate={@handleAuthenticated}
          authenticated={@state.authenticated}
          onSubdomainChange={@handleSubdomainChange}
        />
        <div className="col-xs-12">
          <div className="row">
            {loadStatus}
          </div>
          <div className="row">
            <CardColumn
              title="Done"
              authenticated={@state.authenticated}
              cards={@doneFeatures}
            />
            <CardColumn
              title="Not done"
              authenticated={@state.authenticated}
              cards={@notDoneFeatures}
            />
          </div>
        </div>
      </div>
    )

  handleAuthenticated: (api) ->
    @setState {
      authenticated: true
      numFeatures: NaN
      featuresLoaded: 0
    }
    productKey = "APP"
    api.get "/products/#{productKey}/users", {}, (response) =>
      users = []
      for u in response.project_users
        users.push u.user
      @setState {
        users: users
      }
      api.get "/products/#{productKey}/features", {
        per_page: 300
        updated_since: Date.parse 't - 7d'
      }, (response) =>
        @featuresHash = {}
        @setState {
          numFeatures: response.features.length
        }
        i = 0
        for feature in response.features
          api.get "/features/#{feature.reference_num}", {}, (response) =>
            i++
            @setState {
              featuresLoaded: i
            }
            if response.feature.assigned_to_user
              if not @featuresHash[response.feature.assigned_to_user.id]
                @featuresHash[response.feature.assigned_to_user.id] = []
              @featuresHash[response.feature.assigned_to_user.id].push(response.feature)

  handleSubdomainChange: (subdomain) ->
    @setState {
      subdomain: subdomain
    }

  handleUserSelect: (selection) ->
    @doneFeatures = []
    @notDoneFeatures = []
    if @featuresHash[selection]
      for feature in @featuresHash[selection]
        if feature.workflow_status.name == "Complete" or
           feature.workflow_status.name == "On production"
          @doneFeatures.push feature
        else
          @notDoneFeatures.push feature
    @setState {
      selectedUser: selection
      doneFeatures: @doneFeatures
      notDoneFeatures: @notDoneFeatures
    }
}

AuthenticateControl = React.createClass {

  getInitialState: () ->
    return {
      text: @props.subdomain
    }

  handleChange: () ->
    @props.onSubdomainChange(@refs.subdomainInput.getDOMNode().value)

  handleSubmit: (e) ->
    e.preventDefault()
    new AhaApi {
      accountDomain: @state.text
      clientId: '10218890e8290548ea28cc16d4bbb4e705bcf4f45a4a6cb8632d31cd27b51c78'
      redirectUri: redirectUri
    }
    .authenticate (api, success, message) =>
      @props.onAuthenticate(api)

  render: () ->
    if @props.authenticated == true
      return <div></div>
    else
      return (
        <div className="col-xs-12">
          <div className="form">
            <div className="form-group">
              <label for="subdomain" className="">Aha subdomain</label>
              <input name="subdomain" className="form-control" onChange={@handleChange} defaultValue={@state.text} ref="subdomainInput" />
            </div>
            <div className="form-group">
              <a onClick={@handleSubmit} className="btn btn-primary">Authenticate</a>
            </div>
          </div>
        </div>
      )
}

CardColumn = React.createClass {

  render: () ->
    if not @props.authenticated
      return <div></div>
    cards = []
    renderCard = (c) ->
      return <div key={c.id}><FeatureCard card={c} /></div>
    return (
      <div className="col-xs-6">
        <h3>{@props.title}</h3>
        <div className="row">
          <div className="col-xs-12">
            {@props.cards.map(renderCard)}
          </div>
        </div>
      </div>
    )
}

FeatureCard = React.createClass {

  render: () ->
    if @props.card.workflow_status.name == "Complete" or @props.card.workflow_status.name == "On production"
      cardCls = "panel panel-success"
    else
      cardCls = "panel panel-default"
    requirements = []
    renderRequirement = (r) ->
      if r.workflow_status.name == "Complete" or r.workflow_status.name == "On production"
        cls = "list-group-item list-group-item-success"
      else if r.workflow_status.name == "Rejected"
        cls = "list-group-item list-group-item-danger"
      else
        cls = "list-group-item"
      return <a href={r.url} target="_blank"><li className={cls}><strong>{r.workflow_status.name}</strong> | {r.reference_num} | {r.name}</li></a>
    return (
      <div className={cardCls}>
        <div className="panel-heading"><h3 className="panel-title"><a href={@props.card.url} target="_blank">{@props.card.reference_num} | {@props.card.name}</a></h3></div>
        <ul className="list-group">
          {@props.card.requirements.map(renderRequirement)}
        </ul>
      </div>
    )
}

SelectUserControl = React.createClass {

  handleChange: (e) ->
    @props.onUserSelect(@refs.userSelect.getDOMNode().value)

  render: () ->
    if not @props.users
      return <div></div>
    else
      options = []
      for option in @props.users
        options.push <option value={option.id}>{option.name}</option>
      return (
        <div className="col-xs-12">
          <select className="form-control" onChange={@handleChange} ref="userSelect">
            <option>Choose user...</option>
            {options}
          </select>
        </div>
      )
}

React.render <AhaReport />, document.getElementById('app')