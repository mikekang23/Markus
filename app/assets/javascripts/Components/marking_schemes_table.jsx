import React from 'react';
import {render} from 'react-dom';

import ReactTable from 'react-table';
import {stringFilter} from './table_helpers';


class MarkingSchemeTable extends React.Component {
  constructor() {
    super();
    this.state = {
      data: [],
      columns: [],
    };
    this.fetchData = this.fetchData.bind(this);
  }

  componentDidMount() {
    this.fetchData();
  }

  fetchData() {
    $.ajax({
      url: Routes.populate_marking_schemes_path(),
      dataType: 'json',
    }).then(res => {
      this.setState({
        data: res.data,
        columns: res.columns,
      });
    });
  }

  nameColumns = [
    {
      Header: I18n.t('marking_schemes.name'),
      accessor: 'name',
      filterable: true,
    }
  ];

  modifyColumn = [
    {
      Header: I18n.t('marking_schemes.table_modify_column'),
      Cell: ({original}) => (
        <span>
          <a
            href={original.edit_link}
            data-remote='true'>
            {I18n.t('edit')}
          </a>
          &nbsp;|&nbsp;
          <a
            href={original.delete_link}
            data-method='delete'>
            {I18n.t('delete')}
          </a>
        </span>
      ),
      sortable: false
    },
  ];

  render() {
    return (
      <ReactTable
        data={this.state.data}
        columns={this.nameColumns.concat(this.state.columns).concat(this.modifyColumn)}
        defaultFilterMethod={stringFilter}
        defaultSorted = {[
          {
            id: 'name'
          }
        ]}
      />
    );
  }
}

export function makeMarkingSchemeTable(elem) {
  render(<MarkingSchemeTable/>, elem);
}
