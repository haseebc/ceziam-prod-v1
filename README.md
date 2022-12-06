using terrfaPROD CODE BASE IS https://github.com/haseebc/ceziam-prod-v1

**Purpose:**
This tool is built to aid security engineers, developers and architects to identify the attack surface of a target organisation.

## Evolution
> It is quite a fuss for a developer or security tester to perform an analysis of your domain's attack surface and dangerous ports. Especially, if you do not have access to the required tools. The ultimate goal of this program is to solve this problem providing an automated tool; **running multiple scanning tools to discover vulnerabilities, effectively judge false-positives, collectively correlate results** and **saves precious time**; all these under one roof.<p>Enter **Ceziam**.

## Features
- **one-step security check**.
- **dangerous port check** 
- **attack surface check by enumaerating subdomains**  
- **displays the results spontaneously**
- **Future versions will include API security verification and WebApplication OWASP top10 checks**
- saves a lot of time, **indeed a lot time!**

## Bug Reports
> Ceziam uses Github Issues to keep track of bug reports. Please be sure to include the component of Ceziam that had the issue, steps to reproduce the bug, and a description of what you expect to be the correct behavior.

## Pull Requests
> Ceziam welcomes your code contribution in the form of a Github Pull Request. We will review your request (normally nor more than a day or so)and then merge. We will be sure to properly credit you in the CHANGELOG file, and the commit message will reference the PR number.

Please feel free to connect to ceziam.com and use this feely available Cyber Security tool.

# Ceziam, How It Was Written 
# Table of contents

1. [Overview](#overview)
    1. [Skeleton](#skeleton)
    2. [Gem files to add](#gems)
2. [Frontend](#frontend)
    1. [Views](#views)
3. [Routes](#routes)
4. [Controller](#controller)
5. [Models](#model)
    1. [checks table](#checks)
6. [Attack Engine](#attackengine)
    1. [Attack Calls](#attackcalls)
7. [Java Scripts Used](#js)
    1. [Timer check for script to run](#timerjs)
8. [Redis and Heroku](#redisandheroku)
    1. [Useful Heroku comamnds](#herokucommands)
    2. [Sidekiq overview and how to deploy to Heroku](#sidekiq)
    23. [Sidekiq overview and how to deploy to Heroku](#sidekiq)
9. [Developing & Deploying](#developdeploy)

## Overview
### Skeleton <a name="skeleton"></a>
```bash
rails new \
--database postgresql \
--webpack \
-m https://raw.githubusercontent.com/lewagon/rails-templates/master/devise.rb \
ceziam-prod
```
- Versions: `Rails 6.1.5` `ruby 3.0.3p157`
- Install Node locally from here https://nodejs.org/en/download/
### Gems files to add <a name="gems"></a>
```ruby
gem 'bourbon'
gem 'crack'
gem 'jquery-rails'
gem 'json'
gem 'meta-tags', '~> 2.1'
gem 'net-scp'
gem 'net-ssh'
gem 'pygments.rb'
gem 'redcarpet'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sitemap_generator'
```


## Frontend <a name="frontend"></a>
### Views <a name="views"></a>
`application.html.erb` uses the `stylesheet_link_tag` below.
```ruby
    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
```
The `application.html.erb` we'll improve upon later.

Now get the basic view setup.
You can just copy the URL page as such below. The css won't work, we'll get that setup later.

```html
<!-- SEO Meta-tags -->
<% set_meta_tags title: 'Cyber-security checker',
                description: 'Detect your core cyber security risks including dangerous ports and attack surface with a simple website freely available to all.' %>
<div class="banner-green">
    <%= render 'shared/navbar' %>
    <div class="header-description">
        <h1><p class="header-title">Welcome to Ceziam</p></h1>
        <h2><p
        class="page-description">Detect your core cyber security risks with a simple website freely available to all.</p><h2>
    <form id="search" action="/checks#report-banner-1" method="post">
      <div>
       <%= hidden_field_tag :authenticity_token, form_authenticity_token %>
      <input class="string required" id="check-start" maxlength="255" name="hostname" size="50" type="text" placeholder="Insert your hostname e.g. cnn.com" autocomplete="off"/>
      </div>
      <div class="button-loader-container">
        <input class="button-white" id="button-banner" name="commit" type="submit" value="Detect" />
        <div class="container-animation">
        <div class="circles" id="loading-symbol" hidden>
          <div class="circle-multiple">
            <div class="circle"></div>
            <div class="circle"></div>
            <div class="circle"></div>
          <div class="start-screen">
            <div class="loading">
              <div class="loading__element el1">D</div>
              <div class="loading__element el2">E</div>
              <div class="loading__element el3">T</div>
              <div class="loading__element el4">E</div>
              <div class="loading__element el5">C</div>
              <div class="loading__element el6">T</div>
              <div class="loading__element el7">I</div>
              <div class="loading__element el8">N</div>
              <div class="loading__element el9">G</div>
              <div class="loading__element el13">.</div>
              <div class="loading__element el14">.</div>
              <div class="loading__element el15">.</div>
            </div>
          </div>
          <p class="disclamer">This could take up to 2 minutes...</p>
          </div>
        </div>
      </div>
      </div>
    </form>
    </div>
</div>
<script>
  const form = document.querySelector('#search');
  const gif = document.querySelector("#loading-symbol");
  form.addEventListener('submit', function(event) {
      gif.hidden = false;
  });
</script>
```
### Application.html.erb
This is a core file used to serve views.
Make sure that javascripts are in asset pipeline. This requires new file `/app/assets/javascripts/javascript.js
```javascript
//= require rails-ujs
//= require jquery
//= require bootstrap
//= require_tree .

$(document).ready(function(){
    $( "a.scroll" ).click(function( event ) {
        event.preventDefault();
        $("html, body").animate({ scrollTop: $($(this).attr("href")).offset().top }, 500);
    });
});
```


## Routes
### Routing <a name="routes"></a>
```ruby
  root to: 'pages#home'

  resources :checks do
    resources :vulnerabilities, only: %i[new create]
    get 'full-report'
  end
```
Here we have a root url going to `pages controller/home.html`
```ruby
verb "url", to: "controller#action"
```
## Controller
### Controller <a name="controller"></a>
`rails g controller Checks full_report`
```ruby
      create  app/controllers/checks_controller.rb
       route  get 'checks/full_report'
      invoke  erb
      create    app/views/checks
      create    app/views/checks/full_report.html.erb
      invoke  test_unit
      create    test/controllers/checks_controller_test.rb
```
Then we define methods in the checks_controller.rb
```ruby
  def new
    @check = Check.new
  end

  def create
    hostname_verified = hostname_valid?(params[:hostname])
    if hostname_verified
      @check = Check.new(hostname: hostname_verified)
      @check.user = current_user if current_user
      if @check.save
        if current_user
          redirect_to check_full_report_path(@check)
        else
          session[:last_check_id] = @check.id
          redirect_to check_path(@check)
        end
      else
        flash[:alert] = 'An error occured.'
        redirect_to root_path
      end
    else
      # feeback about non valid hostname
      flash[:alert] = 'Please remove "http://" or enter a valid hostname to run the check.'
      render 'pages/home'
    end
  end

  def show
    @check = Check.find(params[:id])
  end

  def full_report
    @check = Check.find(params[:check_id])
    unless @check.user
      @check.user = current_user
      @check.save
    end
  end

  private

  def hostname_param
    params.require(:check).permit(:hostname)
  end

  def hostname_valid?(user_input)
    valid_hostname_regex = /^(?!:\/\/)([a-zA-Z0-9-_]+\.)*[a-zA-Z0-9][a-zA-Z0-9-_]+\.[a-zA-Z]{2,11}?$/
    user_input.tr!('/', '') if user_input.end_with? '/'
    user_input.match(valid_hostname_regex)
  end
```
We now get the error `uninitialized constant ChecksController::Check`as there is no class called Check. This needs to be done
- model check.rb with Check class 
- model vulnerability.rb with Vulnerability class 
- Services check_service.rb
- Workers hard.worker.rb

#### Resitrations Controller
`rails generate controller RegistrationsController`
```ruby
class RegistrationsController < Devise::RegistrationsController

    before_action :configure_permitted_parameters, if: :devise_controller?
  
    protected
  
    def configure_permitted_parameters
      # For additional fields in app/views/devise/registrations/new.html.erb
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[firstname lastname company])
  
      # For additional in app/views/devise/registrations/edit.html.erb
      devise_parameter_sanitizer.permit(:account_update, keys: %i[firstname lastname company])
      end
  
    def after_sign_up_path_for(_resource)
      check_full_report_path(session[:last_check_id], anchor: 'report-banner-1') if session[:last_check_id]
    end
  
  end
  
```
#### Users Controller
`rails generate controller UsersController`
```ruby
class UsersController < ApplicationController

    def edit
      @user = current_user
    end
  
    def update
      @user = current_user
      if @user.update(user_params)
        redirect_to dashboard_profile_path
      else
        flash[:alert] = 'An error occured.'
        render :edit
      end
    end
  
    private
  
    def user_params
      params.require(:user).permit(:firstname, :lastname, :email, :company, :profilepicture)
    end
  
  end
```
#### Applications Controller
Edit the emply `application_controller.rb`file
```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[firstname lastname company])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: %i[firstname lastname company])
  end

  def after_sign_in_path_for(resource)
    if session[:last_check_id]
      check = Check.find(session[:last_check_id])
      check.user = resource
      check.save
      dashboard_profile_path(resource)
    elsif session[:article_id]
      article_path(Article.find(session[:article_id]))
    else
      request.env['omniauth.origin'] || stored_location_for(resource) || root_path
    end
  end
end
```
#### Dashboard Controller
```bash
rails g controller DashboardController
```

```ruby
class DashboardController < ApplicationController

  def profile
    @checks = current_user.checks
  end

end
```


## Models <a name="model"></a>
We need to create the checks and vulnerabilities table. we can do this by creating a new model or standalone migration. 
Lets do **checks** table first.
### checks table  <a name="checks"></a>
```bash
rails generate model Check ip:string hostname:string scandur:string score:integer user_id:bigint fullresponse:jsonb attacksurface:jsonb domcheck_duration:integer duration:string 
```
This then does the following:
```ruby
      create    db/migrate/20200616101333_create_checks.rb
      create    app/models/check.rb
```
This is an empty model check.rb containing the class Check. And also an migration file for all the new `checks` table. 
```ruby
class CreateChecks < ActiveRecord::Migration[6.0]
  def change
    create_table :checks do |t|
      t.string :ip
      t.string :hostname
      t.string :scandur
      t.integer :score
      t.bigint :user_id
      t.jsonb :fullresponse
      t.jsonb :attacksurface
      t.integer :domcheck_duration
      t.string :duration

      t.timestamps
    end
  end
end
```

`rails db:migrate`
We then get the following table:
```ruby
  create_table "checks", force: :cascade do |t|
    t.string "ip"
    t.string "hostname"
    t.string "scandur"
    t.integer "score"
    t.bigint "user_id"
    t.jsonb "fullresponse"
    t.jsonb "attacksurface"
    t.integer "domcheck_duration"
    t.string "duration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end
```
`rails g migration AddStateToChecks`then update the migration file manually
```ruby
 class AddStateToChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :checks, :state, :string, default: "pending"
  end
end 
```
`rails db:migrate`
Now add the foeign key `rails g migration Checks`, edit the migration file adding the following:
`add_foreign_key :checks, :users`

## Create a New Table called vulnerabilities
```bash
rails generate model Vulnerabilitie port:string protocol:string state:string service:string check_id:bigint version:string reason:string product:string weakness:string risk:string recommandation:string impact:integer likelihood:integer netrisk:integer
```
Manually edit migration file and add:
```ruby
      t.index ["check_id"], name: "index_vulnerabilities_on_check_id"
```

Add the foreign key `rails g migration Vulnerabilities`
```ruby
class Vulnerabilities < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key "vulnerabilities", "checks"
  end
end
```
Note **app/models/vulnerabilitie.rb** has been created and is not used for anything.

Note I had a to rename `vulnerabilitie.rb` to `vulnerability.rb`. What i should have done was rails generate model Vulnerability and all would have been correctly named etc. Lesson learned!




## Improvements
- structure landing page as a html doc.
- Note app/models/vulnerabilitie.rb has been created and is not used for anything. Can be deleted or infuture do a standalone migration instead. 

## Troubleshooting
### Heroku
```bash
heroku ps:exec
```

## Attack Engine <a name="attackengine"></a>
### Attack Calls <a name="attackcalls"></a>
Inputting attack domain results in action /checks#report-banner-1. Create action in checks controller invoked the Check class. The check class is in model check.rb. The Check class method then triggers HardWorker class which then starts the CheckService class run method.

    def run_async_check
        HardWorker.perform_async(id)
    end
CheckService class run method is the calling of the scripts to launch the attack.

## Java Scripts Used <a name="js"></a> 
### Timer check for script to run <a name="timerjs"></a> 
`views/checks/show.html.erb`
```html
<% if @check.completed? %>
<p> check completed

<% else %>

<p> scan in progress

<script>
    setTimeout(function(){
      window.location.reload(1);
    }, 30000);
</script>

<% end %>
```
## Troubleshooting: Redis, Heroku, Db <a name="redisandheroku"></a> 
### Useful Heroku comamnds <a name="herokucommands"></a> 
```bash
heroku logs --tail
heroku restart
```

### Sidekiq overview and how to deploy it to Heroku <a name="sidekiq"></a> 
**Procfile** Write this as follows:
```
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
```
**sidekiq.yml**
The point of this is to adhere to the lciensing requirements of Redis, keep to throttle the number of workers. Can be increased later witha  cost of using pro version of redistogo.
```
:concurrency:  3
```
**Heroku change** Make sure in Heroku Resources menu the `bundle exec sidekiq -C config/sidekiq.yml`is activated.
Also do follwoing in Heroku
```heroku config:set REDIS_PROVIDER=REDISTOGO_URL``` as described here https://github.com/mperham/sidekiq/wiki/Using-Redis#using-an-env-variable
####redis.rb####
```ruby
$redis = Redis.new

url = ENV['REDISTOGO_URL']

if url
  Sidekiq.configure_server do |config|
    config.redis = { url: url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: url }
  end
  $redis = Redis.new(url: url)
end
```
### Database <a name="database"></a> 
DATABASE RESTART
>rails db:reset

DATABASE DOES NOT START
>rm /usr/local/var/postgres/postmaster.pid


DATABASE NEEDS TOBE MANUALLY STARTED
```ruby
DATABASE RESTART
>rails db:reset

DATABASE DOES NOT START
>rm /usr/local/var/postgres/postmaster.pid
brew services restart postgresql
pg_ctl -D /usr/local/var/postgres start
rails db:create
```
#### Use logs on Heroku GUI to view what happens when dyno restarts

#### Always check redis and sidekiq versions when nothing happens

#### Use binding.pry for skipping through the app 
  
#### Useful Links
https://devcenter.heroku.com/articles/redistogo

## Developing & Deploying <a name="developdeploy"></a>
We have a production site and a development site in Heroku.
### Heroku Development
https://devceziamv1.herokuapp.com/
```ruby
heroku create devceziamv1 --region eu

git remote add develop git@heroku.com:devceziamv1.git

git push develop master

heroku config:set REDIS_PROVIDER=REDISCLOUD_URL --app devceziamv1

heroku run rails db:migrate --app devceziamv1
```   
    
### Heroku Production
https://ceziamv1.herokuapp.com/

### Heroku Development
https://git.heroku.com/ceziam-prod.git


### Github Production
https://github.com/haseebc/ceziam-prod/
    

  
### Git settings production
```bash
git remote -v
heroku  https://git.heroku.com/ceziamv1.git (fetch)
heroku  https://git.heroku.com/ceziamv1.git (push)
origin  git@github.com:haseebc/ceziam-prod.git (fetch)
origin  git@github.com:haseebc/ceziam-prod.git (push)
```

### Github
#### origin/master
We consider origin/master to be the main branch where the source code of HEAD always reflects a production-ready state.
#### origin/develop
We consider origin/develop to be the main branch where the source code of HEAD always reflects a state with the latest delivered development changes for the next release. 
When the source code in the develop branch reaches a stable point and is ready to be released, all of the changes should be merged back into master somehow and then tagged with a release number.  
#### Prod rollout 
Therefore, each time when changes are merged back into master, this is a new production release by definition. We tend to be very strict at this, so that theoretically, we could use a Git hook script to automatically build and roll-out our software to our production servers everytime there was a commit on master.
    
### Github Dev Lifecycle New
#### New Development Branch
You can list all of your current branches like this:
```bash
git branch -a
```
	
To push the new branch
```bash
git checkout -b development
git push origin development
```

#### Making changes on development
git checkout development
 When making changes, add and commit as usual:
```bash
 	git add .
	git commit -m "whatever"
```

 The first time you push to your remote do it like so:
 ```bash
	git push -u origin development
 ```

 The -u flag stands for --set-upstream. After the first time you only need to do it like this:
 ```bash
	git push
 ```
    
#### Merging development to main
Once your develop is ready to merge into main you can do it like so:
 
First switch to your local main branch:
 ```bash
git checkout main
 ```	
To merge develop into main do the following:
 ```bash
git merge development
 ```
Then push the changes in local main to the remote master:
 ```bash
git push
 ```	  

#### Deleting a branch
If you don't need the develop branch anymore, or you just want to delete it and start over, you can do the following:

Delete the remote develop branch:
 ```bash
git push -d origin develop
```	 
Then delete the local branch:
```bash
git branch -d develop
```
The -d means delete.

# **Technical Solution Design: SIEM Productionisation**
- [Overview](#TechnicalSolutionDesign:SIEMProductionisation-Overview) 
  - [SOC](#TechnicalSolutionDesign:SIEMProductionisation-SOC)
  - [Scope](#TechnicalSolutionDesign:SIEMProductionisation-Scope) 
    - [In Scope](#TechnicalSolutionDesign:SIEMProductionisation-InScope)
    - [Out of Scope](#TechnicalSolutionDesign:SIEMProductionisation-OutofScope)
- [Requirements](#TechnicalSolutionDesign:SIEMProductionisation-Requirements) 
  - [Deployment](#TechnicalSolutionDesign:SIEMProductionisation-Deployment) 
    - [Documentation](#TechnicalSolutionDesign:SIEMProductionisation-Documentation)
  - [Use cases](#TechnicalSolutionDesign:SIEMProductionisation-Usecases) 
    - [Documentation](#TechnicalSolutionDesign:SIEMProductionisation-Documentation.1)
  - [Log sources](#TechnicalSolutionDesign:SIEMProductionisation-Logsources) 
    - [Documentation](#TechnicalSolutionDesign:SIEMProductionisation-Documentation.2)
  - [Build View Dashboard](#TechnicalSolutionDesign:SIEMProductionisation-BuildViewDashboard)
- [Architecture](#TechnicalSolutionDesign:SIEMProductionisation-Architecture)
- [PoC Sentinel Build](#TechnicalSolutionDesign:SIEMProductionisation-PoCSentinelBuild) 
  - [Manual Configuration](#TechnicalSolutionDesign:SIEMProductionisation-ManualConfiguration)
  - [Connecting Zscaler](#TechnicalSolutionDesign:SIEMProductionisation-ConnectingZscaler) 
    - [Network Diagram of Zscaler configuration](#TechnicalSolutionDesign:SIEMProductionisation-NetworkDiagramofZscalerconfiguration)
  - [MS Defender365](#TechnicalSolutionDesign:SIEMProductionisation-MSDefender365) 
    - [Sandbox Test Lab](#TechnicalSolutionDesign:SIEMProductionisation-SandboxTestLab)
  - [AsCode Deployment Configuration](#TechnicalSolutionDesign:SIEMProductionisation-AsCodeDeploymentConfiguration) 
    - [Deploying Arm Templates using Terraform](#TechnicalSolutionDesign:SIEMProductionisation-DeployingArmTemplatesusingTerraform)
  - [Log Analysis](#TechnicalSolutionDesign:SIEMProductionisation-LogAnalysis) 
    - [Reduce data that is been sent/injected by Sentinel](#TechnicalSolutionDesign:SIEMProductionisation-Reducedatathatisbeensent/injectedbySentinel) 
      - [At the source level](#TechnicalSolutionDesign:SIEMProductionisation-Atthesourcelevel)
      - [At ingestion time](#TechnicalSolutionDesign:SIEMProductionisation-Atingestiontime)
    - [How to View ingested Logs](#TechnicalSolutionDesign:SIEMProductionisation-HowtoViewingestedLogs)
  - [Data Retention options](#TechnicalSolutionDesign:SIEMProductionisation-DataRetentionoptions)
- [Design Decisions](#TechnicalSolutionDesign:SIEMProductionisation-DesignDecisions)
- [Risks / Issues](#TechnicalSolutionDesign:SIEMProductionisation-Risks/Issues)
- [Definitions](#TechnicalSolutionDesign:SIEMProductionisation-Definitions)
- [References](#TechnicalSolutionDesign:SIEMProductionisation-References)
# **Overview**
Overview of solution/Business case

Objective is to have some monitoring/detection/alerting capabilities in our SIEM Sentinel
Requirements for version 0.1.
### **SOC**
The Unilabs SOC will be **a centralized command center for Unilabs cybersecurity needs**. It is a 24/7 capability staffed with cybersecurity experts (MSSP) to monitor our security posture and identify potential threats real-time. The most important purpose of the SOC is to centralize all cybersecurity operations.
## **Scope**
### **In Scope**
- Log ingestion into a central Sentinel instance
- Secure transport of log events 
- All required Sentinel components 
- Use or required security controls in Azure for instance Appln Gateway WAF and Azure NSGs
- DevOps process followed 
- Definition and implementation of uses cases
- Documentation 
### **Out of Scope**
- Alert management. 
- Full SOC capability with associated workflow
# **Requirements**
## **Deployment**
DevOps process followed (Terraform, MS GitHub repo, Merge, Deploy into Azure). Infrastructure as code. the justification being manual changes kept to a minimum, one stable repo in organization and we can then at a later stage perform security policy as code.
#### **Documentation** 
Documentation detailing how DevOps deployment is performed is required.
## **Use cases**
Development of basic uses case associated with integrated log sources. For instance: multiple account logons failed, malware detected in multiple endpoints, connection allowed to malicious website among others.
#### **Documentation** 
Documentation detailing use case logic is required. The documentation should include comprehensive information for troubleshooting use cases.
## **Log sources**
Following log sources should be transferred securely into Sentinel.

- Active Directory events 
- Cynet events
- Office 365 evets into Sentinel
- Zscaler logs

Verification of data ingestion and parsing is required.
#### **Documentation** 
Documentation detailing log sources configuration is required. The documentation should include comprehensive information for troubleshooting log sources issues and replicate integration in new environments. 
## **Build View Dashboard**
Basic view of logs that have been generated from different log sources
# **Architecture**
A possible architecture is detailed below. Please note this is only a first iteration.

![](Aspose.Words.431f63cc-8cb8-485d-b05d-9c0bc23cb5af.001.png) 

Deployement as code using terraform

resource "azurerm\_log\_analytics\_solution" "la-opf-solution-sentinel" {

`  `solution\_name         = "SecurityInsights"

`  `location              = "${azurerm\_resource\_group.rgcore-example-management.location}"

`  `resource\_group\_name   = "${azurerm\_resource\_group.rgcore-example-management.name}"

`  `workspace\_resource\_id = "${azurerm\_log\_analytics\_workspace.rgcore-management-la.id}"

`  `workspace\_name        = "${azurerm\_log\_analytics\_workspace.rgcore-management-la.name}"

`  `plan {

`    `publisher = "Microsoft"

`    `product   = "OMSGallery/SecurityInsights"

`  `}

}
# **PoC Sentinel Build**
## **Manual Configuration**

|**Step #**|**Activity**|**Details**|**What we did 110822**|
| :-: | :-: | :-: | :-: |
|1|Prerequisites|<p>To enable Microsoft Sentinel, you need **contributor** permissions to the subscription </p><p>To use Microsoft Sentinel, you need either **contributor** or **reader** permissions on the resource group </p>|<p>- Create sentinal</p><p>- Add workspace to Sentinal “WEu T VM LOG1”</p><p>- Trial for 11th Sept 2022</p><p>- Click Ok</p>|
|2 |Test syslog source|Deploy a test VM in a test resource group <br>ssh key for auth<br>West Europe (Zone 1)<br>Disk B1s general purpose<br>Linux (ubuntu 20.04)||
|3|Configure syslog source|<p>1. From the Microsoft Sentinel navigation menu, select Data connectors.</p><p>2. From the connectors gallery, select Syslog and then select Open connector page.</p><p>3. Select the Download & install agent for Azure Linux Virtual machines </p>|<p>- selected Azure AD to connector </p><p>- selected all configuration options</p><p>- Connectot</p><p>- Office 365 Exchange and Teams added</p>|
|4|Log analytics agent |Linux Appliance<br>Log onto portal, select Microsoft Sentinal, Create a workspace||
|5|Configure log analytics agent |<p>MS native data connection</p><p>1. From the Microsoft Sentinel navigation menu, select Data connectors.</p><p>2. Select a data connector, and then select the Open connector page button.</p><p>3. The connector page shows instructions for configuring the connector, and any other instructions that may be necessary.</p><p>For example, if you select the Azure Active Directory data connect to</p>||
||||**What was done 310822**|
|6|Connecting Zscaler|<p>**VM Data Connector Deployed**</p><p>*Subscription<br>AzureSimple for Unilabs Group Services<br>Resource group<br>WEu-P-SecurityAdmin-RG1<br>Virtual machine name<br>WEu-P-Sent-SRV1<br>Region<br>West Europe<br>Availability options<br>Availability zone<br>1<br>Ubuntu Server 18.04 LTS - Gen2<br>SSH public key<br>azureuser<br>WEu-P-sent\_srv1<br>Virtual network<br>WEu-P-SecurityAdmin-RG1-vnet<br>Subnet<br>default (10.3.0.0/24)<br>Public IP<br>WEu-P-Sent-SRV1-ip*</p>||
|||<p>**VM Data Connector** **NSG**</p><p>interface [weu-p-sent-srv1422_z1](https://portal.azure.com/)</p><p>Allow Tcp 514 inbound any </p>||
||||**What was done 040922**|
|7|Nanolog Streaming Service (NSS)<br>prerequisites|Get pre requisites met from <br>Sery get instructions, certs and secret token for .vhd file||
||NSS storage account reaction|<p>1. create storage account<br>   create blob storage<br>   zsnssdeployment<br>   for copying VHD files from Zscaler storage acc<br>   TEMPLATE <br>   <https://secengsentnssstorageacc1.blob.core.windows.net/zsnssdeployment/znss_5_0_eu_osdisk.vhd></p><p>zsnssprod</p><p><https://zsprodeu.blob.core.windows.net/?sv=2019-02-02&ss=b&srt=sco&sp=rl&se=2023-03-12T09:14:30Z&st=2020-03-12T00:14:30Z&spr=https&sig=u5yagWaZdC343ZOcFkefwKTrkNT07Gs3qx3Y3YeCda0%3D><br>CORRECT this was used to create the blob</p>||
||Creating the 2 network interfaces and a public IP in Azure|<p>create net interface<br>For mgmt traffic<br>weu-p-sent-nssmgmt<br>resource group<br>WEu-P-SecurityAdmin-RG1<br>10.3.0.10<br>Virtual network/subnet<br>WEu-P-SecurityAdmin-RG1-vnet/default</p><p>create net interface<br>For syslog traffic<br>weu-p-sent-nsssrvc<br>resource group<br>WEu-P-SecurityAdmin-RG1<br>10.3.0.11<br>Virtual network/subnet<br>WEu-P-SecurityAdmin-RG1-vnet/default<br>owner<br>securityeng<br>project<br>sentinel</p><p>Public IP<br>WEu-P-Sent-nssmgmt-ip<br>20.224.8.145<br>Associated to<br>weu-p-sent-nssmgmt</p>||
||Create code for deployment|<p>name=AzureNSS</p><p>location=westeurope</p><p>rgname=WEu-P-SecurityAdmin-RG1</p><p>createrg=n</p><p>storename=secengsentnssstorageacc1</p><p>createstorage=n</p><p>vnetname=WEu-P-SecurityAdmin-RG1-vnet</p><p>vnetprefix=10.3.0.0/16</p><p>mgmtsubnetname=default</p><p>mgmtsubnetprefix=10.3.0.0/24</p><p>svcsubnetname=default</p><p>svcsubnetprefix=10.3.0.0/24</p><p>niccount=2</p><p>vmsize=Standard\_A4\_v2</p><p>dstStorageURI=https://secengsentnssstorageacc1.blob.core.windows.net</p><p>dstContainer=zsnssprod</p><p>srcOsURI=https://secengsentnssstorageacc1.blob.core.windows.net/zsnssdeployment/znss\_5\_0\_eu\_osdisk.vhd</p>||
||Deploy in Azure|launch the script<br>./deployment\_script.ps1 config\_file.txt||
||Security|<p>Change root pw</p><p><zsroot@20.107.6.93></p><p>Strong password applied.</p>||
||Install certificates|<p>[zsroot@NSS ]:-$sudo nss install-cert NssCertificate.zip</p><p>Password:</p><p>Detected an Azure VM!!</p><p>Certificates successfully installed</p><p>[zsroot@NSS ]:-$sudo nss dump-config</p><p>Detected an Azure VM!!</p><p>/sc/conf/sc.conf does not exist</p><p>Configured Values:</p><p>`	`CloudName:zscaler.net</p><p>`	`nameserver:168.63.129.16	</p><p>`	`smnet\_dev:</p><p>`	`Default gateway for Service IP:</p><p>`	`Routes for Siem N/w:</p><p>[zsroot@NSS ]:-$</p>||
||NSS VM network change|<p>zsroot@20.107.6.93</p><p>`	`Enter the command sudo nss configure</p><p>`	 `service interface IP address with netmask</p><p>`	`Did the following changes 	 </p><p>`	`[zsroot@NSS ]:-$sudo nss configure</p><p>Password:</p><p>Detected an Azure VM!!</p><p>nameserver:168.63.129.16 (Options <c:change, d:delete, n:no change>) [n]</p><p>Do you wish to add a new nameserver? <n:no y:yes> [n]: </p><p>smnet\_dev (Service interface IP address with netmask) []: 10.3.0.6</p><p>Please re-enter netmask after IP address: (Ex.1.2.3.4/24)</p><p>smnet\_dev (Service interface IP address with netmask) []: 10.3.0.6/24</p><p>smnet\_dflt\_gw (Service interface default gateway IP address) []: 10.3.0.1</p><p>Successfully Applied Changes</p><p>[zsroot@NSS ]:-$</p>||
||Updates and check connectivity to central command and control server|<p>[zsroot@NSS ]:-$sudo nss update-now</p><p>Password:</p><p>Connecting to server...</p><p>Downloading latest version</p><p>Installing build /sc/smcdsc/nss\_upgrade.sh</p><p>Finished installation!</p><p>[zsroot@NSS ]:-$sudo nss checkversion</p><p>Connecting to server...</p><p>Connecting to update server 104.129.195.114.</p><p>Installed build version: 329792</p><p>Latest available build version: 329792</p><p>[zsroot@NSS ]:-$sudo nss start</p><p>Detected an Azure VM!!</p><p>NSS service running with pid 1606</p><p>[zsroot@NSS ]:-$sudo nss enable-autostart</p><p>Password:</p><p>Detected an Azure VM!!</p><p>Auto-start of NSS enabled </p><p>[zsroot@NSS ]:-$sudo nss troubleshoot netstat|grep tcp</p><p>//+SHARED MEMORY KEY 17 (/sc/)</p><p>tcp          0(  0%)        0(  0%) 10.3.0.6.7422          104.129.195.85.443    ESTABLISHED</p><p>[zsroot@NSS ]:-$</p>||
||Deploy NSGs to newly created VMS|Deployed to NSS VM public interface||
||Zscaler change made by Sergy|Zscaler command and control update with IP of SIEM and port||
||Add connector to Azure|<p>From Azure sentinel click connect Azure connector choosing Zscaler </p><p>Instal CEF connector</p><p>sudo wget -O cef\_installer.py https://raw.githubusercontent.com/Azure/Azure-Sentinel/master/DataConnectors/CEF/cef\_installer.py&&sudo python cef\_installer.py 6a5d5fba-6562-4ec7-84b3-cfccddc3489b 0jXXRObjN5oTArSTxTErd8Ckpt4Efd0ETiNsodWt6USKJDwDGDLddDYBFbds8DiJvKCdiStcAzAeIA/ZyxcN5A==</p>||
||Validation|<p>Validate the connection</p><p>sudo wget -O cef\_troubleshoot.py https://raw.githubusercontent.com/Azure/Azure-Sentinel/master/DataConnectors/CEF/cef\_troubleshoot.py&&sudo python cef\_troubleshoot.py  6a5d5fba-6562-4ec7-84b3-cfccddc3489b</p>||
||Confirm logs received|<p>Check for logs on the Data connector VM</p><p>tcpdump -A -ni any port 25226 -vv</p>||
## **Connecting Zscaler**
### **Network Diagram of Zscaler configuration**
![](Aspose.Words.431f63cc-8cb8-485d-b05d-9c0bc23cb5af.002.png) 
## **MS Defender365**
Defender365 as a log source has been added. All sources were included as detailed below.

Name

Description

DeviceInfo

Machine information (including OS information)

DeviceNetworkInfo

Network properties of machines

DeviceProcessEvents

Process creation and related events

DeviceNetworkEvents

Network connection and related events

DeviceFileEvents

File creation, modification, and other file system events

DeviceRegistryEvents

Creation and modification of registry entries

DeviceLogonEvents

Sign-ins and other authentication events

DeviceImageLoadEvents

DLL loading events

DeviceEvents

Additional events types

DeviceFileCertificateInfo

Certificate information of signed files

Microsoft Defender for Office 365 (5/5 connected)​

Name

Description

EmailEvents

Office 365 email events, including email delivery and blocking events

EmailUrlInfo

Information about URLs on Office 365 emails

EmailAttachmentInfo

Information about files attached to Office 365 emails

EmailPostDeliveryEvents

Security events that occur post-delivery, after Office 365 has delivered an email message to the recipient mailbox

UrlClickEvents

Events involving URLs clicked, selected, or requested on Microsoft Defender for Office 365

Microsoft Defender for Cloud Apps (1/1 connected)​

Name

Description

CloudAppEvents

Events involving accounts and objects in Office 365 and other cloud apps and services

Microsoft Defender for Identity (3/3 connected)​

Name

Description

IdentityLogonEvents

Authentication activities made through your on-premises Active Directory

IdentityQueryEvents

Information about queries performed against Active Directory objects

IdentityDirectoryEvents

Captures various identity-related events

Microsoft Defender Alert Evidence (1/1 connected)​

Name

Description

AlertEvidence

Files, IP addresses, URLs, users, or devices associated with alerts.
### **Sandbox Test Lab**
Sandbox Connection to non Unilabs environment

ssh -i /Users/haseebchaudhary/code/Cloud/azure/sentineltest\_key.pem azureuser@20.86.2.219
## **AsCode Deployment Configuration**
### **Deploying Arm Templates using Terraform**
This is generally a very bad idea should be only used as a last resort, explained in [here](https://docs.microsoft.com/en-us/azure/sentinel/detect-threats-custom).
## **Log Analysis**
### **Reduce data that is been sent/injected by Sentinel**
#### **At the source level**
Go the CEF agent and filter unnecessary evets. This will block data to arrive to LA WS and highly recommended for noisy/unrelated data.

![](Aspose.Words.431f63cc-8cb8-485d-b05d-9c0bc23cb5af.003.png) 

So in the Simpler example you see they filter out events of service user (svc-)

Youtub with demo: [Azure Sentinel webinar: Log forwarder deep dive on filtering CEF and syslog events - YouTube](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DbHw8BkEpYzs&data=05%7C01%7Chaseeb.chaudhary%40unilabs.com%7C7843da3d315c4e7456ef08da956a0011%7C30a5585b3b79491abc1e5cfe51faf766%7C0%7C0%7C637986579758910924%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=Cnvnn84JmMowdACFenUSmXlq1Y9DGkngCv6%2Fq3Azxmo%3D&reserved=0)
#### **At ingestion time**
Data will arrive to LA WS and will be filtered out

[Custom data ingestion and transformation in Microsoft Sentinel (preview) | Microsoft Docs](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Fsentinel%2Fdata-transformation&data=05%7C01%7Chaseeb.chaudhary%40unilabs.com%7C7843da3d315c4e7456ef08da956a0011%7C30a5585b3b79491abc1e5cfe51faf766%7C0%7C0%7C637986579758910924%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=xiOy8U5a4OyIqr85R721IZpIq6rbTsN4tM%2BbNs5tHZI%3D&reserved=0)
### **How to View ingested Logs** 
## **Data Retention options**
As Azure Sentinel is solution on top of Log Analytics, we effectively defining this here. When you enable Azure Sentinel you are entitled for 90 retention without extra cost.

` `Beyond 90 days, we have couple of options:

1. [preferred way] Retention policy and archiving, [Configure data retention and archive in Azure Monitor Logs (Preview) - Azure Monitor | Microsoft Docs](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Fazure-monitor%2Flogs%2Fdata-retention-archive%3Ftabs%3Dportal-1%252Cportal-2&data=05%7C01%7Chaseeb.chaudhary%40unilabs.com%7C7843da3d315c4e7456ef08da956a0011%7C30a5585b3b79491abc1e5cfe51faf766%7C0%7C0%7C637986579758910924%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=wUeWh6jvUPXz%2FY%2BnO6VX14AreTYZBF4d8PfooM5A2ws%3D&reserved=0)
   1. Retention policy can be different for each table
   1. Archiving is set on table level
1. Archiving to storage account, [Archive data from Log Analytics workspace to Azure storage using Logic App - Azure Monitor | Microsoft Docs](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Fazure-monitor%2Flogs%2Flogs-export-logic-app&data=05%7C01%7Chaseeb.chaudhary%40unilabs.com%7C7843da3d315c4e7456ef08da956a0011%7C30a5585b3b79491abc1e5cfe51faf766%7C0%7C0%7C637986579758910924%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=m43anuJc%2FB8961rZ7I5WRGA8OZxnTgZlaU4MGhhKu6c%3D&reserved=0)
   1. There is a logic app that pulls data from LAWS and sends it to storage account
   1. One downside it that searching data stored in storage account is more complex
1. Sending data to Azure Data Explorer, [Using Azure Data Explorer for long term retention of Microsoft Sentinel logs - Microsoft Tech Community](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Ftechcommunity.microsoft.com%2Ft5%2Fmicrosoft-sentinel-blog%2Fusing-azure-data-explorer-for-long-term-retention-of-microsoft%2Fba-p%2F1883947&data=05%7C01%7Chaseeb.chaudhary%40unilabs.com%7C7843da3d315c4e7456ef08da956a0011%7C30a5585b3b79491abc1e5cfe51faf766%7C0%7C0%7C637986579758910924%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=GKgAp3lBZOLhtRe%2BhWWQ%2F92ZSxmnxOrjzPT489Od7so%3D&reserved=0)

Analytics Rules with FastTrack

Analyse the inbuilt rules shipped

should we review what connectors are implemented?

disable new rule built?

Use what we have out of the box and then create.

No analytic rules needed for MS Defender. As “Connect Microsoft 365 Defender​ incidents to your Microsoft Sentinel. Incidents will appear in the incidents queue.“
# **Design Decisions**

||**Decision**|**By Whom**|**Date**|
| :-: | :-: | :-: | :-: |
|1|Use four log sources for ver 1.0|Daniel, Deborah, Haseeb|20-07-2022|
|2|Cloud native connections for log ingestion, not private network||07-08-2022|
|3|Use a dedicated subscription, test in AzureSimple for Unilabs Group||07-08-2022|
|4|Nomenclature in Azure|<p>Weu-T-VMs-SEN1</p><p>location-env-resourcetype-object</p>|07-08-2022|
|5|Tagging guide to use?|<p>owner = jsmith</p><p>confidentiality = private<br><br>env = dev</p>|07-08-2022|
|6|Segregate operational and security date, Azure dedicated workspace between for operational and security data?|To be discussed|07-08-2022|
|7|Azure Regions, keeping data in a particular geography, then create a separate workspace for each region with such requirements.|To be discussed|07-08-2022|
|8|Data ownership, create separate workspaces to define data ownership, eg example by subsidiaries or affiliated companies.|To be discussed|07-08-2022|
|9|Access control, roles and permissions?|To be discussed|07-08-2022|
|10|Size of NSS VM has 2 vCPUs and 8GB memory, Standard\_A4\_v2. Is this adequate?|To be discussed|03-09-2022|
|11|Size of Dataconnector VM. Is this adequate?|To be discussed|03-09-2022|
|12|<p>Do we need an event hub or data collector in the design?</p><p>Impact? Cost?</p><p>It was recommended by FastTrack not to use a data hub at this time. The justification for this is logs can be filtered out at ingestion time for now.</p>|FastTrack meeting|13/09/2022|
|13|Include log sources to include Defender 365. Justification:<br>Provide information for a number of use cases for instance repeat login failures relating to Ransomware.|HC and DP|97/09/2022|
# **Risks / Issues**

|**Issues/Risk**|**Status**|**Date**|
| :-: | :-: | :-: |
|What will be log retention policy? Default is 90 days.|||
|<p>Using an automated deployment method has been challenged by Prociso. It has been suggested it will be replaced and provides no value if there are are no associated mature security controls such as code scanning.</p><p>[Recommendation from Microsoft is to use automation and Terraform](https://azure.microsoft.com/mediahandler/files/resourcefiles/azure-sentinel-deployment-guide/Microsoft_Azure%20Sentinel_Managed_Sentinel_Deployment_Guide.pdf).<br>Manual. Using the Azure portal, the administrator manually configures the Azure Sentinel resources. *Any manual process has the inherent risks of human operator error, lack of compliance with potential change control procedures, and undocumented changes. Automation tools**.** Azure Sentinel resources support AsCode tools, such as Hashicorp Terraform, that can provide consistency to processes.*</p>|||
|Tighten NSGs for VMs installed in Azure|Needs to be done||
|Apply SSH keys for two VMs: VM Data connector and AzureNSS. At moment is ssh and strong password|Needs to be done||
|Unanticipated costs from Azure Sentinel? |||
# **Definitions**

|**Term**|**Definition**|
| :-: | :-: |
|Group Log source||
|||
# **References**

|**Document**|**Link**|**Author**|**Topic**|
| :-: | :-: | :-: | :-: |
|Azure Sentinel Deployment Guide|[https://azure.microsoft.com/mediahandler/files/resourcefiles/azure-sentinel-deployment-guide/Microsoft_Azure Sentinel_Managed_Sentinel_Deployment_Guide.pdf](https://azure.microsoft.com/mediahandler/files/resourcefiles/azure-sentinel-deployment-guide/Microsoft_Azure%20Sentinel_Managed_Sentinel_Deployment_Guide.pdf)|Microsoft||
|Microsoft Quickstart Guide|<https://docs.microsoft.com/en-us/azure/sentinel/quickstart-onboard>|Microsoft||
|Design a Log Analytics workspace architecture|<https://docs.microsoft.com/en-us/azure/azure-monitor/logs/workspace-design>|Microsoft||
|Resource naming and tagging decision guide|<https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/decision-guides/resource-tagging/>|Microsoft||
|Get fine-tuning recommendations for your analytics rules in Microsoft Sentinel|<https://docs.microsoft.com/en-us/azure/sentinel/detection-tuning>|Microsoft|Azure Sentinel Fine Tuning|
|Create custom analytics rules to detect threats|<https://docs.microsoft.com/en-us/azure/sentinel/detect-threats-custom>|Deploying ARM Templates with Terraform|Azure Sentinel custom analytics rules|
|Quickstart: Onboard Microsoft Sentinel|<https://docs.microsoft.com/en-us/azure/sentinel/quickstart-onboard>|Microsoft|Sentinel Quickstart|
|Zscaler|<https://help.zscaler.com/zia/zscaler-microsoft-azure-sentinel-deployment-guide>|Zscaler from Sergy|Zscaler|
|Zscaler with Sentinel Detailed|<https://help.zscaler.com/zia/nss-deployment-guide-microsoft-azure>|Zscaler from Sergy||
|Zscaler Sentinel integration|<https://community.zscaler.com/t/guide-deploy-zscaler-nss-in-azure/8571>|Community Zscaler||
|Sentinel Overall Documentation|<https://docs.microsoft.com/en-gb/azure/sentinel/>|Microsoft||
|||||
|Sentinel Documentation General|- [Microsoft Sentinel documentation | Microsoft Docs](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdocs.microsoft.com%2Fen-gb%2Fazure%2Fsentinel%2F&data=05%7C01%7Chaseeb.chaudhary%40unilabs.com%7Cb37f766f966c450368f408da8f50bbd2%7C30a5585b3b79491abc1e5cfe51faf766%7C0%7C0%7C637979874159819595%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=29%2BJfRrbg8p8Q4Q045tGK2DL46ijyWIAT7JT5ZLAwrk%3D&reserved=0)|Microsoft||
|Sentinel Pricing Docs |<p>- [Azure Sentinel Pricing | Microsoft Azure](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fazure.microsoft.com%2Fen-us%2Fpricing%2Fdetails%2Fmicrosoft-sentinel%2F&data=05%7C01%7Chaseeb.chaudhary%40unilabs.com%7Cb37f766f966c450368f408da8f50bbd2%7C30a5585b3b79491abc1e5cfe51faf766%7C0%7C0%7C637979874159819595%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=TAghdWI7N%2B8niHn6hs33jjOePEFWDeoL27l6lYPvN1o%3D&reserved=0)</p><p>- [Plan costs, understand Microsoft Sentinel pricing and billing | Microsoft Docs](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdocs.microsoft.com%2Fen-gb%2Fazure%2Fsentinel%2Fbilling%3Ftabs%3Dcommitment-tier&data=05%7C01%7Chaseeb.chaudhary%40unilabs.com%7Cb37f766f966c450368f408da8f50bbd2%7C30a5585b3b79491abc1e5cfe51faf766%7C0%7C0%7C637979874159819595%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=yP%2FKt1uNDeVs6N7zjechWaYLwQCuzqbV9KOynpTxoFA%3D&reserved=0)</p><p>- [Cost Management + Billing - Microsoft Cost Management | Microsoft Docs](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Fcost-management-billing%2F&data=05%7C01%7Chaseeb.chaudhary%40unilabs.com%7Cb37f766f966c450368f408da8f50bbd2%7C30a5585b3b79491abc1e5cfe51faf766%7C0%7C0%7C637979874159819595%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=hhg2E7bPRt4vHmBYf4d5tX%2FkV9%2F1WaMtvzFolibMEik%3D&reserved=0)</p><p>- [Tutorial - Create and manage Azure budgets | Microsoft Docs](https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Fcost-management-billing%2Fcosts%2Ftutorial-acm-create-budgets&data=05%7C01%7Chaseeb.chaudhary%40unilabs.com%7Cb37f766f966c450368f408da8f50bbd2%7C30a5585b3b79491abc1e5cfe51faf766%7C0%7C0%7C637979874159819595%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=4jc%2BKXtTml%2BT00W0zmeedV4QscAiU2VFCgbUYjjWwWg%3D&reserved=0)</p>|Microsoft|Sentinel Pricing|
|Mapping threat to tech environments |<https://docs.microsoft.com/en-gb/azure/architecture/solution-ideas/articles/map-threats-it-environment>||Use case development|
|||||
|||||

