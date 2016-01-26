//= require mock-ajax

describe('DashboardGrid', function () {
  var dashboard;
  var testTitle = "Concierge";
  var testUuid = "123456789";
  var testPath = '/widget_path';
  var rowHeight = 100;
  var maxColumns = 12;
  var testLayout = {
    x: 3,
    y: 0,
    h: 2,
    w: 6
  };
  var widgetProps = {
    uuid: testUuid,
    title: testTitle,
    layout: testLayout,
    widget_path: testPath
  };
  var editMode=false;
  var fakeWindowRedirect = jasmine.createSpy('fakeWindowRedirect')

  beforeEach(function() {
    dashboard = window.TestUtils.renderIntoDocument(
      <DashboardGrid widgets={[widgetProps]} dashboardId='1' editMode={editMode} onSave={fakeWindowRedirect}/>
    );
  });

  it('renders the widget', function () {
    var titleNode = window.TestUtils.findRenderedDOMComponentWithTag(
      dashboard,
      'h4'
    )
    expect(titleNode.textContent).toEqual(testTitle);
  });

  it('renders the widget with correct height', function(){
    var widgetHeight = parseInt(window.TestUtils.findRenderedDOMComponentWithClass(dashboard, 'widget').style.height.replace("px",""));
    var delta = 15;
    expect(widgetHeight).toBeGreaterThan((rowHeight*2) - delta);
    expect(widgetHeight).toBeLessThan((rowHeight*2) + delta);
  });

  it('renders the widget with correct width', function() {
    var widgetWidth = parseInt(window.TestUtils.findRenderedDOMComponentWithClass(dashboard, 'widget').style.width.replace("%",""));
    var delta = 3;
    expect(widgetWidth).toBeGreaterThan(50 - delta); //Note: 50% - 6 of 12 columns
    expect(widgetWidth).toBeLessThan(50 + delta);
  });

  describe('not in edit mode', function () {
    beforeEach(function() {
      dashboard = window.TestUtils.renderIntoDocument(<DashboardGrid widgets={[widgetProps]} dashboardId='1' editMode={false}/>);
    });

    it('does not allow dragging', function() {
      expect(dashboard.getDOMNode().innerHTML).not.toContain("react-draggable")
    });

    it('does not allow resizing', function() {
      expect(dashboard.getDOMNode().innerHTML).not.toContain("react-resizable")
    });
  });

  describe('in edit mode', function () {
    beforeEach(function() {
      dashboard = window.TestUtils.renderIntoDocument(<DashboardGrid widgets={[widgetProps]} dashboardId='1' editMode={true}/>);
    });

    it('allows dragging', function() {
      expect(dashboard.getDOMNode().innerHTML).toContain("react-draggable");
    });

    it('allows resizing', function() {
      expect(dashboard.getDOMNode().innerHTML).toContain("react-resizable");
    });
  });

  describe('update layout',function(){
    it('initialized the current layout with widget layout', function() {
      expectedLayout = _.extend(testLayout, {"i": testUuid});
      expect(currentLayout).toEqual([expectedLayout]);
    });

    it('saves the provided layout as current layout', function() {
      newLayout = 'new Layout';
      dashboard.updateLayout(newLayout);
      expect(currentLayout).toEqual(newLayout);
    });
  });

  describe('persist layout',function(){
    beforeEach(function() {
      jasmine.Ajax.install();
    });

    afterEach(function() {
      jasmine.Ajax.uninstall();
    });

    var doPersist = function(){ dashboard.persistLayout() };

    it('sends the current layout to the server', function() {
      currentLayout = 'new Layout';
      doPersist();

      request = jasmine.Ajax.requests.mostRecent();
      expect(request.url).toBe('/api/dashboards/1/layout');
      expect(request.method).toBe('PUT');
      expect(request.data()).toEqual({layout: "new Layout"});
    });

    describe('when layout is successfully saved',function(){
      beforeEach(function(){
        doPersist();
        request = jasmine.Ajax.requests.mostRecent();
        request.respondWith({ status: 200, responseText: '{}' });
      });

      it('reloads the page in view-only mode', function() {
        expect(fakeWindowRedirect.calls.count()).toBe(1);
      });
    });
  });
});