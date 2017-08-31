//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import Actions from './actions'
import EnrollmentActions from '../../enrollments/actions'
import {
  View,
  StyleSheet,
  FlatList,
} from 'react-native'

import find from 'lodash/find'
import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import SubmissionsHeader, { type SubmissionFilterOption, type SelectedSubmissionFilter } from '../../submissions/SubmissionsHeader'
import SubmissionRow, { type SubmissionRowDataProps } from '../../submissions/list/SubmissionRow'
import mapStateToProps from './map-state-to-props'
import Images from '../../../images'
import i18n from 'format-message'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'

export type QuizSubmissionListNavProps = {
  courseID: string,
  quizID: string,
  filterType: ?string,
  refresh: Function,
  navigator: Navigator,
}

export type QuizSubmissionListDataProps = {
  rows: SubmissionRowDataProps[],
  quiz: QuizState,
  pending: boolean,
  error: ?string,
  pointsPossible: number,
  anonymous: boolean,
}

export type QuizSubmissionListProps = QuizSubmissionListDataProps & QuizSubmissionListNavProps

export class QuizSubmissionList extends Component<any, QuizSubmissionListProps, any> {

  filterOptions: SubmissionFilterOption[]
  selectedFilter: ?SelectedSubmissionFilter

  constructor (props: any) {
    super(props)

    this.filterOptions = this.filterOptions = SubmissionsHeader.defaultFilterOptions()
    this.state = {
      rows: props.rows || [],
    }
  }

  navigateToSubmission = (index: number) => (userID: string) => {
    const { quiz, courseID } = this.props
    if (!quiz.data.assignment_id) return
    const path = `/courses/${courseID}/assignments/${quiz.data.assignment_id}/submissions/${userID}`

    this.props.navigator.show(
      path,
      { modal: true, modalPresentationStyle: 'fullscreen' },
      { selectedFilter: this.selectedFilter, studentIndex: index }
    )
  }

  componentWillMount = () => {
    const type = this.props.filterType
    if (type) {
      const filter = find(this.filterOptions, { type })
      if (filter) {
        this.selectedFilter = { filter }
      }
      this.updateRows(this.props.rows)
    }
  }

  componentWillReceiveProps = (newProps: QuizSubmissionListProps) => {
    this.updateRows(newProps.rows)
  }

  updateFilter = (filter: SelectedSubmissionFilter) => {
    this.selectedFilter = filter
    this.updateRows(this.props.rows)
  }

  clearFilter = () => {
    this.selectedFilter = null
    this.updateRows(this.props.rows)
  }

  updateRows = (rows: SubmissionRowDataProps[]) => {
    const selected = this.selectedFilter
    let filtered = rows
    if (selected && selected.filter && selected.filter.filterFunc) {
      filtered = selected.filter.filterFunc(rows, selected.metadata)
    }

    this.setState({
      rows: filtered,
    })
  }

  renderRow = ({ item, index }: { item: SubmissionRowDataProps, index: number }) => {
    let disclosure = true
    if (this.props.quiz) {
      disclosure = !!this.props.quiz.data.assignment_id
    }
    return <SubmissionRow
      {...item}
      onPress={this.navigateToSubmission(index)}
      disclosure={disclosure}
      anonymous={this.props.anonymous}
    />
  }

  keyExtractor = (item: SubmissionRowDataProps) => {
    return item.userID
  }

  openSubmissionSettings = () => {
    this.props.navigator.show(
      `/courses/${this.props.courseID}/assignments/${this.props.quiz.data.assignment_id}/submission_settings`,
      { modal: true }
    )
  }

  render () {
    let rightBarButtons = []
    if (this.props.quiz && this.props.quiz.data.assignment_id) {
      rightBarButtons.push({
        accessibilityLabel: i18n('Submission Settings'),
        image: Images.course.settings,
        testID: 'quiz-submissions.settings',
        action: this.openSubmissionSettings,
      })
    }

    return (
      <Screen
        title={i18n('Submissions')}
        subtitle={this.props.courseName}
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        rightBarButtons={rightBarButtons}
      >
        {this.props.pending && !this.props.refreshing
          ? <ActivityIndicatorView />
          : <View style={styles.container}>
              <SubmissionsHeader
                filterOptions={this.filterOptions}
                selectedFilter={this.selectedFilter}
                onClearFilter={this.clearFilter}
                onSelectFilter={this.updateFilter}
                pointsPossible={this.props.pointsPossible}
                anonymous={this.props.anonymous}
                muted={this.props.muted} />
              <FlatList
                data={this.state.rows}
                keyExtractor={this.keyExtractor}
                testID='quiz-submission-list'
                renderItem={this.renderRow}
                refreshing={this.props.refreshing}
                onRefresh={this.props.refresh}
                />
            </View>
        }
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    paddingTop: 16,
    paddingBottom: 12,
    paddingHorizontal: 16,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2d3b44',
  },
  filterButton: {
    marginBottom: 1,
  },
})

export function refreshQuizSubmissionData (props: any): void {
  const { courseID, quizID } = props
  props.refreshQuizSubmissions(courseID, quizID)
  props.refreshEnrollments(courseID)
}

let Refreshed = refresh(
  refreshQuizSubmissionData,
  props => true,
  props => Boolean(props.pending)
)(QuizSubmissionList)
let Connected = connect(mapStateToProps, { ...Actions, ...EnrollmentActions })(Refreshed)
export default (Connected: Component<any, QuizSubmissionListProps, any>)
