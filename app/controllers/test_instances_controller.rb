class TestInstancesController < BasicUserController
  before_action :set_test_instance, only: [:show, :edit, :update, :destroy]

  # GET /test_instances
  # GET /test_instances.json
  def index
    @test_instances = TestInstance.all
  end

  # GET /test_instances/1
  # GET /test_instances/1.json
  def show
  end

  # GET /test_instances/new
  def new
    @test_instance = TestInstance.new
  end

  # GET /test_instances/1/edit
  def edit
  end

  # POST /test_instances
  # POST /test_instances.json
  def create
    @test_instance = TestInstance.new
    @test_case = TestCase.find(params[:test_case_id])
    @test_instance.title = @test_case.title
    @test_instance.description = @test_case.description
    @test_instance.expected_result = @test_case.expected_result
    @test_instance.sql_statement = @test_case.sql_statement
    @test_instance.user_id = params[:user_id]
    @test_instance.test_run_id = params[:test_run_id]
    @test_instance.save
=begin
    @sql_client = TinyTds::Client.new(
      :username => ENV["SQL_USERNAME"], 
      :dataserver => ENV["SQL_DATASERVER"], 
      :password => ENV["SQL_PASSWORD"],
      :database => ENV["SQL_DATABASE"], 
      :port => 1433
    )

    @postgres_client = PG.connect(
      :dbname   => 'int_waldorf_namely_production',
      :host     => 'database-featureteam-hcm-proddatav1.namely.run',
      :user     => 'svc_waldorf',
      :password => '6jhny6OtNtuyEF1pfLmUFr2mF',
      :sslmode  => 'prefer',
      :port     => 5432
    )

    results = @postgres_client.execute('select TOP 5 * from HCM_Profiles')

    #record result

    t.boolean  "pass_flag"
    t.integer  "user_id"
    t.integer  "test_instance_id"
    t.integer  "test_run_id"
    t.integer  "table_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "output"
=end
    respond_to do |format|
      if @test_instance.save
        format.html { redirect_to @test_instance, notice: 'Test instance was successfully created.' }
        format.json { render :show, status: :created, location: @test_instance }
      else
        format.html { render :new }
        format.json { render json: @test_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /test_instances/1
  # PATCH/PUT /test_instances/1.json
  def update
    respond_to do |format|
      if @test_instance.update(test_instance_params)
        format.html { redirect_to @test_instance, notice: 'Test instance was successfully updated.' }
        format.json { render :show, status: :ok, location: @test_instance }
      else
        format.html { render :edit }
        format.json { render json: @test_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_instances/1
  # DELETE /test_instances/1.json
  def destroy
    @test_instance.destroy
    respond_to do |format|
      format.html { redirect_to test_instances_url, notice: 'Test instance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_instance
      @test_instance = TestInstance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_instance_params
      params.require(:test_instance).permit(:test_case_id, :user_id, :test_run_id)
    end
end
