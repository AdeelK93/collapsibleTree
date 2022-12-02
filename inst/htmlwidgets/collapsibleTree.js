HTMLWidgets.widget({

  name: 'collapsibleTree',
  type: 'output',

  factory: function(el, width, height) {

    var i = 0,
    duration = 750,
    root = {},
    options = {},
    newnest = {},
    treemap;

    // Optionally enable zooming, and limit to 1/5x or 5x of the original viewport
    var zoom = d3.zoom()
    .scaleExtent([1/5, 5])
    .on('zoom', function () {
      svg.attr('transform', d3.event.transform);
    });

    // create our tree object and bind it to the element
    // appends a 'group' element to 'svg'
    // moves the 'group' element to the top left margin
    var svg = d3.select(el).append('svg')
    .attr('width', width)
    .attr('height', height)
    .append('g');
    //.attr("viewBox", "0 "+(-1*(height-margin.top-margin.bottom)/2)+" "+width+" "+height);

    // Define the div for the tooltip
    var tooltip = d3.select(el).append('div')
    .attr('class', 'tooltip')
    .style('opacity', 0);

    function update(source) {

      // Assigns the x and y position for the nodes
      var treeData = treemap(root);

      // Compute the new tree layout.
      var nodes = treeData.descendants(),
      links = treeData.descendants().slice(1);

      // Normalize for fixed-depth.
      nodes.forEach(function(d) {d.y = d.depth * options.linkLength});

      // ****************** Nodes section ***************************

      // Update the nodes...
      var node = svg.selectAll('g.node')
      .data(nodes, function(d) {

        if (d.depth > 1) {
          d.root_id = d.parent.root_id;
        } else {
          d.root_id = d.id;
        }

        return d.id || (d.id = ++i);
      });

      // Enter any new nodes at the parent's previous position.
      var nodeEnter = node.enter().append('g')
      .attr('class', 'node')
      .attr('transform', function(d) {
        return 'translate(' + source.y0 + ',' + source.x0 + ')';
      })
      .on('click', click);

      // Add tooltips, if specified in options
      if (options.tooltip) {
        nodeEnter = nodeEnter
        .on('mouseover', mouseover)
        .on('mouseout', mouseout);
      }

      // Enable zooming, if specified
      if (options.zoomable) d3.select(el).select('svg').call(zoom);

      // Add Circle for the nodes
      nodeEnter.append('circle')
      .attr('class', 'node')
      .attr('r', 1e-6)
      .attr('r', function(d) {
        //return Math.log(d.data.SizeOfNode) || 5; // default radius was 10, reduced to 5
        return Math.sqrt(d.data.SizeOfNode); // default radius was 10, reduced to 5
      })
      .style('stroke-width', function(d) {
        return d._children ? 1 : 1;
      });

      // Add labels for the nodes
      nodeEnter.append('text')
      .attr('class', 'node-text')
      .attr('dy', '.35em')
      .attr('x', function(d) {
        // Scale padding for label to the size of node
        //var padding = (Math.log(d.data.SizeOfNode) || 5) + 3;
        var padding = (Math.sqrt(d.data.SizeOfNode)) + 3;
        return d.children || d._children ? padding : padding;
      })
      .style('font-size', options.fontSize + 'px')
      .text(function(d) { return d.data.name; });

      // UPDATE
      var nodeUpdate = nodeEnter.merge(node);

      // Transition to the proper position for the node
      nodeUpdate.transition()
      .duration(duration)
      .attr('transform', function(d) {
        return 'translate(' + d.y + ',' + d.x + ')';
      });

      // Update the node attributes and style
      nodeUpdate.select('circle.node')
      .style('fill', function(d) {
        if (d._isSelected === true){
          return options.fill;
        } else {
          return '#FFF';
        }
      })
      .attr('cursor', 'pointer');

      // Update the node-text attributes and style
      nodeUpdate.select('text.node-text')
      .attr('text-anchor', function(d) {
        if(d.children){
            return 'end';
        } else {
            return 'start';
        }
      })
      .attr('x', function(d) {
        //var padding = (Math.log(d.data.SizeOfNode) || 5) + 3;
        var padding = (Math.sqrt(d.data.SizeOfNode)) + 3;
        if(d.children){
            return -1 * padding;
        } else {
            return padding;
        }
      })
      .style('font-size', function(d) {
        if (d._isSelected === true) {
            return (options.fontSize + 1) + 'px';
        } else {
            return (options.fontSize) + 'px';
        }
      })
      .style('font-weight', function(d) {
        if (d._isSelected === true) {
            return 'bolder';
        } else {
            return 'lighter';
        }
      });

      // Remove any exiting nodes
      var nodeExit = node.exit().transition()
      .duration(duration)
      .attr('transform', function(d) {
        return 'translate(' + source.y + ',' + source.x + ')';
      })
      .remove();

      // On exit reduce the node circles size to 0
      nodeExit.select('circle')
      .attr('r', 1e-6)
      .attr('class', 'hidden');

      // On exit reduce the opacity of text labels
      nodeExit.select('text')
      .style('fill-opacity', 1e-6);

  // ****************** links section ***************************

      // Update the links...
      var link = svg.selectAll('path.link')
      .data(links, function(d) { return d.id; });

      // Enter any new links at the parent's previous position.
      var linkEnter = link.enter().insert('path', 'g')
      .attr('class', 'link')
      // Potentially, this may one day be mappable
      // .style('stroke-width', function(d) { return d.data.linkWidth || 1 })
      .attr('d', function(d){
        var o = { x: source.x0, y: source.y0 };
        return diagonal(o, o);
      });

      // UPDATE
      var linkUpdate = linkEnter.merge(link);

      // Transition back to the parent element position
      linkUpdate.transition()
      .duration(duration)
      .attr('d', function(d){ return diagonal(d, d.parent) });

      // Remove any exiting links
      var linkExit = link.exit().transition()
      .duration(duration)
      .attr('d', function(d) {
        var o = {x: source.x, y: source.y};
        return diagonal(o, o);
      })
      .remove();

      // Store the old positions for transition.
      nodes.forEach(function(d){
        d.x0 = d.x;
        d.y0 = d.y;
      });

      // Creates a curved (diagonal) path from parent to the child nodes
      function diagonal(s, d) {

        path = 'M ' + s.y + ' ' + s.x + ' C ' +
        (s.y + d.y) / 2 + ' ' + s.x + ', ' +
        (s.y + d.y) / 2 + ' ' + d.x + ', ' +
        d.y + ' ' + d.x;

        return path;
      }

      newnest = nodes.filter(nodes => nodes.depth > 0 && nodes._isSelected === true).map(function(nd) {
        return {
            id: nd.root_id,
            parent: nd.parent.data.name,
            level: options.hierarchy[nd.depth - 1],
            value: nd.data.name
        };
      });

      // Toggle children on click.
      function click(d) {

        // toggle children
        if (d.children) {
          d._children = d.children;
          d.children = null;
        } else {
          d.children = d._children;
          d._children = null;
        }

        // toggle _isselected
        if (d._isSelected == false || d._isSelected == null){
          d._isSelected = true;
        } else {
          d._isSelected = false;
        }

        // toggle node state
        //if (d.state === undefined || d.state == "closed") {
        //  d.state = "open";
        //} else {
        //  d.state = "closed";
        //}

        var t = d3.zoomTransform(svg.node());
        var x = -source.y0;
        var y = -source.x0;
        var new_x = x * t.k + width / 6;
        var new_y = y * t.k + height / 2;

        svg.transition().duration(750).attr("transform", "translate(" + new_x + "," + new_y + ")");

        update(d);

        // Hide the tooltip after clicking
        tooltip.transition()
        .duration(100)
        .style('opacity', 0);

        // Update Shiny inputs, if applicable
        if (options.input) {
          var nest = {},
          obj = d;
          // Navigate up the list and recursively find parental nodes
          for (var n = d.depth; n > 0; n--) {

            // ONLY add to `nest` IFF selected (i.e. `._isSelected == true`)
            if (obj._isSelected == true) {
              if (nest[options.hierarchy[n-1]] === undefined) {
                nest[options.hierarchy[n-1]] = obj.data.name;
              } else {
                nest[options.hierarchy[n-1]].push(obj.data.name);
              }
            }
            obj = obj.parent;
          }

          // WeightOfNode == 0 for `n` nodes
          // if (d.data.WeightOfNode > 0) {
          //  Shiny.setInputValue(options.input, nest, { priority: "event" });
          // }
          // Shiny.setInputValue(options.input, nest, { priority: "event" });

          Shiny.setInputValue(options.input, JSON.stringify(newnest), { priority: "event" });
        }
      }

      // Show tooltip on mouseover
      function mouseover(d) {
        tooltip.transition()
        .duration(200)
        .style('opacity', .9);

        // Show either a constructed tooltip, or override with one from the data
        tooltip.html(
          d.data.tooltip || d.data.name + '<br>' +
          options.attribute + ': ' + d.data.WeightOfNode
        )
        // Make the tooltip font size just a little bit bigger
        .style('font-size', (options.fontSize + 1) + 'px')
        .style('left', (d3.event.layerX) + 'px')
        .style('top', (d3.event.layerY - 10) + 'px');
      }

      // Hide tooltip on mouseout
      function mouseout(d) {
        tooltip.transition()
        .duration(500)
        .style('opacity', 0);
      }
    }

    return {
      renderValue: function(x) {
        // Assigns parent, children, height, depth
        root = d3.hierarchy(x.data, function(d) { return d.children; });
        root.x0 = height / 2;
        root.y0 = 0;
        root._isSelected = true;

        // Attach options as a property of the instance
        options = x.options;

        // Update the canvas with the new dimensions
        svg = svg.attr('transform', 'translate('
        + options.margin.left + ',' + options.margin.top + ')')

        // width and height, corrected for margins
        var heightMargin = height - options.margin.top - options.margin.bottom,
        widthMargin = width - options.margin.left - options.margin.right;

        // declares a tree layout and assigns the size
        treemap = d3.tree().size([heightMargin, widthMargin])
        .separation(separationFun);
        update(root);

        // Calculate a reasonable link length, if not otherwise specified
        if (!options.linkLength) {
          options.linkResponsive = true
          options.linkLength = 2 * (widthMargin / options.hierarchy.length)
          if (options.linkLength < 175) {
            options.linkLength = 175 // Offscreen or too short
          }
        }

        // Optionally collapse after the second level
        if (options.collapsed) root.children.forEach(collapse);
        update(root);

        // Collapse the node and all it's children
        function collapse(d) {
          // A collapsed data value was specified and is true
          if(d.children && options.collapsed in d.data && !d.data[options.collapsed]) {
            d.children.forEach(collapse)
          } else if(d.children) {
            d._children = d.children
            d._children.forEach(collapse)
            d.children = null
          }
        }
      },

      resize: function(width, height) {
        // Resize the canvas
        d3.select(el).select('svg')
        .attr('width', width)
        .attr('height', height);

        // width and height, corrected for margins
        var heightMargin = height - options.margin.top - options.margin.bottom,
        widthMargin = width - options.margin.left - options.margin.right;

        // Calculate a reasonable link length, if not originally specified
        if (options.linkResponsive) {
          options.linkLength = 2 * (widthMargin / options.hierarchy.length)
          if (options.linkLength < 175) {
            options.linkLength = 175 // Offscreen or too short
          }
        }

        // Update the treemap to fit the new canvas size
        treemap = d3.tree().size([heightMargin, widthMargin])
        .separation(separationFun);
        update(root)

      },
      // Make the instance properties available as a property of the widget
      svg: svg,
      root: root,
      options: options
    };
  }
});

function separationFun(a, b) {
  var height = Math.sqrt(a.data.SizeOfNode) + Math.sqrt(b.data.SizeOfNode),
  // Scale distance to SizeOfNode, if defined
  distance = (height) / 25; // increase denominator for better spacing in DEAP app
  //if (distance < .4) {
  //  distance = .4
  //}
  //console.log(distance);
  return (a.parent === b.parent ? distance : 1);
};
