require 'prawn/layout'
class UsersController < ApplicationController
  before_filter :access_required, :only => [:index, :destroy]
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    if @user.save
      case true
      when params[:email].present?
        flash[:notice] = "Your CV has been sent on email"
        EmailMailer.deliver_email_with_attachment(@user.email,draw_pdf)
      when params[:export].present?
        send_data draw_pdf, :filename => "yourcv.pdf", :type => "application/pdf" and return
      else
        flash[:notice] = 'User was successfully created.' 
      end
      redirect_to root_url
    else
      render :action => "new"
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  private
  def access_required
    flash[:error] = "You do not have access to view this page"
    redirect_to root_url
  end

  def draw_pdf(user = @user)
    pdf = Prawn::Document.new(:page_size => 'A4', :layout => 'portrait') do
      move_down(10)
      #text "Site is under development............", :size => 42, :align => :right
      text user.name, :size => 15, :align => :right
      #stroke horizontal_rule
      stroke do
        rectangle [0,745], 525, 1
      end
      move_down(1)
      # Image
      #image 'public/images/sandip.png', :scale => 0.5, :position => :left
      require "open-uri"
      begin
        image open(user.photo_url), :height => 100, :position => :left
      rescue
      end if user.photo_url
      
      move_down(5)
      
      text user.tagline, :size => 12
      text user.email, :size => 12

      move_down(21)
      # Summary here
      text "Summary", :style => :bold
      text user.summary
      
      move_down(21)
      text "Personal Details", :style => :bold
      
      move_down(5)
      data = [
        ["Name", {:text => user.name, :font_style => :bold, :colspan => 4 }],
        ["Address", {:text => user.address, :colspan => 4 }],
        ["Mobile", {:text => user.mobile, :colspan => 4 }],
        ["Birth Date", {:text => user.designation, :colspan => 4 }],
        ["Nationality", {:text => user.nationality, :colspan => 4 }],
        ["Education", {:text => user.education, :colspan => 4 }],
        ["Languages", {:text => user.languages, :colspan => 4 }],
        [{:text => "Areas of Speciality", :font_style => :bold}, {:text => user.areas_of_speciality, :font_style => :bold, :colspan => 4}],
        [{:text => "Website"},{:text => user.website, :colspan => 4}],
        [{:text => "Designation"},{:text => user.designation, :colspan => 4}],
        [{:text => "Company"},{:text => user.company, :colspan => 4}]
      ]
      table data,
        :border_style => :grid, #:underline_header
        :font_size => 10,
        :horizontal_padding => 6,
        :vertical_padding => 3,
        :border_width => 0.7,
        :column_widths => { 0 => 130, 1 => 100, 2 => 100, 3 => 100, 4 => 80 },
        :position => :left,
        :align => { 0 => :left, 1 => :left, 2 => :left, 3 => :right, 4 => :right }
      if user.interests
        move_down(5)
        text "Interests", :style => :bold
        text user.interests
      end
    end
    pdf.render
  end
end
