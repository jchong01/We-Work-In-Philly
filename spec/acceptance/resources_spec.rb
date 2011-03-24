require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

def setup_resources
  DatabaseCleaner.clean
  @first  = Factory(:resource)
  @second = Factory(:resource)
  @third  = Factory(:resource)
  @resources = [@first, @second, @third]
end

feature "The resource index" do
  background do
    setup_resources
  end

  scenario "should list resources by category" do
    visit resources_path
    page.should have_css "ul.resources", :count => @resources.map(&:category).uniq.count
    @resources.each do |resource|
      page.should have_content resource.name
    end
  end
end

feature "The resource show page" do
  background do
    setup_resources
  end

  scenario "does not exist. Visitors should be sent to the resource index." do
    visit resource_path(@first)
    current_path.should == resources_path
  end
end

feature "The resource delete button" do
  background do
    setup_resources
  end

  scenario "should delete resources" do
    signed_in_as(:user) do
      visit resources_path
      page.should have_content @first.name

      visit edit_resource_path(@first)
      click_link "Delete"

      visit resources_path
      page.should_not have_content @first.name
    end
  end
end

feature "The new resource form" do
  scenario "should allow users to add a resource" do
    # where attributes are defined as the things that are actually stored on the resource model, not tags or other bits
    signed_in_as(:user) do
      visit new_resource_path
      @from_factory = Factory.build(:resource)

      within 'form.resource' do
        fill_in 'resource_name', :with => @from_factory.name
        fill_in 'resource_category', :with => @from_factory.category
        fill_in 'resource_description', :with => @from_factory.description
        fill_in 'resource_url', :with => @from_factory.url
        click_button 'resource_submit'
      end

      page.should have_selector 'ul.resources'
      page.should have_content @from_factory.name
      page.should have_content @from_factory.category
      page.should have_content @from_factory.description
    end
  end

  scenario "should not be accessible to anonymous users" do
    visit new_resource_path
    current_path.should == new_user_session_path
  end
end

feature "The resource edit form" do
  background do
    setup_resources
  end

  scenario "should not be accessible by anonymous users" do
    visit edit_resource_path(@first)

    current_path.should == new_user_session_path
    page.should have_content "sign in"
  end

  scenario "should be accessible to users" do
    signed_in_as(:user) do
      visit edit_resource_path(@first)

      current_path.should == edit_resource_path(@first)
      page.should have_selector('form.resource')
    end
  end

  scenario "should allow editing of a resource's attributes" do
    # where attributes are defined as the things that are actually stored on the resource model, not tags or other bits
    signed_in_as(:user) do
      visit edit_resource_path(@first)

      within 'form.resource' do
        fill_in 'resource_name', :with => @first.name.reverse
        fill_in 'resource_category', :with => @first.category.reverse
        fill_in 'resource_description', :with => @first.description.reverse
        fill_in 'resource_url', :with => @first.url.reverse
        click_button 'resource_submit'
      end

      current_path.should == resources_path
      page.should have_content @first.name.reverse
      page.should have_content @first.category.reverse
      page.should have_content @first.description.reverse
    end
  end
end

