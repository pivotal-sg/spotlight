require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe WidgetsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Widget. As you add validations to Widget, be sure to
  # adjust the attributes here as well.

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # WidgetsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #new" do
    it "assigns a new widget as @widget" do
      get :new, {}, valid_session
      expect(assigns(:widget)).to be_a_new(Widget)
    end
  end

  describe "POST #create" do
    let!(:dashboard) { FactoryGirl.create :dashboard  }
    let(:valid_attributes) { {title: 'test'} }

    context "with valid params" do
      it "creates a new Widget" do
        expect {
          post :create, {:widget => valid_attributes}, valid_session
        }.to change(Widget, :count).by(1)
      end

      it "assigns a newly created widget as @widget" do
        post :create, {:widget => valid_attributes}, valid_session
        expect(assigns(:widget)).to be_a(Widget)
        expect(assigns(:widget)).to be_persisted
      end

      it "redirects to the created widget" do
        post :create, {:widget => valid_attributes}, valid_session
        expect(response).to redirect_to(edit_widget_path(Widget.last))
      end
    end

    context "with invalid params" do
      context "title missing" do
        let(:invalid_attributes) { {title: nil} }

        it "assigns a newly created but unsaved widget as @widget" do
          post :create, {:widget => invalid_attributes}, valid_session
          expect(assigns(:widget)).to be_a_new(Widget)
        end

        it "re-renders the 'new' template" do
          post :create, {:widget => invalid_attributes}, valid_session
          expect(response).to render_template("new")
        end
      end

      context "title is too long" do
        let(:invalid_attributes) { {title: Faker::Lorem.characters(61) } }

        it "assigns a newly created but unsaved widget as @widget" do
          post :create, {:widget => invalid_attributes}, valid_session
          expect(assigns(:widget)).to be_a_new(Widget)
        end

        it "re-renders the 'new' template" do
          post :create, {:widget => invalid_attributes}, valid_session
          expect(response).to render_template("new")
        end
      end
    end
  end

  describe "GET #edit" do
    let(:widget) { FactoryGirl.create :ci_widget, :with_default_dashboard }
    it "assigns the widget as @widget" do
      get :edit, {:id => widget.id}
      expect(assigns(:widget)).to eq widget
    end
  end

  describe "GET #update" do
    let!(:widget) { FactoryGirl.create :ci_widget, :with_default_dashboard }

    context 'for travis CI widget' do
      context 'valid attributes' do
        let(:params) { {id: widget.id, ci_widget: { travis_url: 'url', travis_auth_key: 'auth_key'}}}

        it "updates the widget" do
          expect {
            patch :update, params
          }.to change{Widget.last.travis_url}.from(nil).to('url')
        end

        it "assigns a newly created widget as @widget" do
          patch :update, params
          expect(assigns(:widget)).to eq widget
        end

        it "redirects to dashboard" do
          patch :update, params
          expect(response).to redirect_to(dashboards_path)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:widget) { FactoryGirl.create :ci_widget, :with_default_dashboard }

    it "deletes the widget" do
      expect {
        delete :destroy, id: widget.id
      }.to change{Widget.count}.from(1).to(0)
    end

    it "redirects to dashboard" do
      delete :destroy, id: widget.id
      expect(response).to redirect_to(dashboards_path)
    end
  end
end
