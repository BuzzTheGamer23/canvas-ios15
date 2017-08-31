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
import {
  View,
  StyleSheet,
  ActivityIndicator,
  FlatList,
  LayoutAnimation,
} from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import { Heading1, Text } from '../../common/text'
import colors from '../../common/colors'
import RubricItem from './components/RubricItem'
import SpeedGraderActions from './actions'
import GradePicker from './components/GradePicker'
import CommentInput from './comments/CommentInput'
import DrawerState from './utils/drawer-state'

export class GradeTab extends Component {
  props: GradeTabProps
  state: GradeTabState

  constructor (props: GradeTabProps) {
    super(props)
    this.state = {
      ratings: props.rubricAssessment || {},
      criterionCommentInput: null,
    }
  }

  componentWillReceiveProps (nextProps: GradeTabProps) {
    if (this.props.rubricGradePending && !nextProps.rubricGradePending) {
      this.setState({
        criterionCommentInput: null,
        ratings: nextProps.rubricAssessment || {},
      })
    }
  }

  showDescriptionModal = (rubricID: string) => {
    const { courseID, assignmentID } = this.props
    const url = `/courses/${courseID}/assignments/${assignmentID}/rubrics/${rubricID}/description`
    this.props.navigator.show(url, { modal: true })
  }

  updateScore = (id: string, value: ?number) => {
    this.setState((prevState) => {
      let newRatings = {
        ratings: {
          ...this.state.ratings,
          [id]: {
            ...this.state.ratings[id],
            points: value,
          },
        },
      }

      this.props.updateUnsavedChanges(newRatings.ratings)
      return newRatings
    })
  }

  getCurrentScore = () => {
    return Object.keys(this.state.ratings)
      .reduce((sum, key) => sum + (this.state.ratings[key].points || 0), 0)
  }

  saveRubricAssessment = (newRating: { [string]: RubricAssessment }) => {
    this.props.gradeSubmissionWithRubric(
      this.props.courseID,
      this.props.assignmentID,
      this.props.userID,
      this.props.submissionID,
      {
        ...this.props.rubricAssessment,
        ...newRating,
      }
    )
  }

  openCommentKeyboard = (criterionID: string) => {
    this.setState({ criterionCommentInput: criterionID })
  }

  submitRubricComment = ({ message }: { message: string }) => {
    if (!this.state.criterionCommentInput) return
    let id = this.state.criterionCommentInput
    let currentAssessment = this.props.rubricAssessment || {}
    let newRating = {
      [id]: {
        ...currentAssessment[id],
        comments: message,
      },
    }
    this.setState({
      ratings: {
        ...this.state.ratings,
        ...newRating,
      },
    })
    this.saveRubricAssessment(newRating)
  }

  cancelRubricComment = () => {
    LayoutAnimation.easeInEaseOut()
    this.setState({
      criterionCommentInput: null,
    })
  }

  deleteComment = (criterionID: string) => {
    let currentAssessment = this.props.rubricAssessment || {}
    let newRating = {
      [criterionID]: {
        ...currentAssessment[criterionID],
        comments: '',
      },
    }
    this.setState({
      ratings: {
        ...this.props.rubricAssessment,
        ...newRating,
      },
    })
    this.saveRubricAssessment(newRating)
  }

  renderHeader = () => {
    let settings = this.props.rubricSettings
    return (
      <View>
        <GradePicker {...this.props} useRubricForGrading={this.props.useRubricForGrading} rubricScore={this.getCurrentScore()}/>
        {this.props.rubricItems &&
          <View style={styles.rubricHeader}>
            <View>
              <Heading1>{i18n('Rubric')}</Heading1>
              <Text style={styles.pointsText}>
                {
                  i18n('{points, number} out of {totalPoints, number}', {
                    points: this.getCurrentScore(),
                    totalPoints: settings && settings.points_possible,
                  })
                }
              </Text>
            </View>
            {this.props.rubricGradePending &&
              <ActivityIndicator />
            }
          </View>
        }
      </View>
    )
  }

  renderRubricItem = ({ item }: { item: Rubric }) => {
    let settings = this.props.rubricSettings
    return (
      <RubricItem
        key={item.id}
        rubricItem={item}
        freeFormCriterionComments={settings.free_form_criterion_comments}
        showDescription={this.showDescriptionModal}
        changeRating={this.updateScore}
        grade={this.state.ratings[item.id]}
        openCommentKeyboard={this.openCommentKeyboard}
        deleteComment={this.deleteComment}
        showToolTip={this.props.showToolTip}
        dismissToolTip={this.props.dismissToolTip}
      />
    )
  }

  renderCommentInput = () => {
    if (!this.state.criterionCommentInput) return null

    let rating = this.state.ratings[this.state.criterionCommentInput] || {}
    return (
      <CommentInput
        initialValue={rating.comments}
        makeComment={this.submitRubricComment}
        onBlur={this.cancelRubricComment}
        allowMediaComments={false}
        autoCorrect={false}
        drawerState={this.props.drawerState}
        autoFocus
      />
    )
  }

  render () {
    let items = this.props.rubricItems || []
    return (
      <View style={{ flex: 1 }}>
        <FlatList
          ListHeaderComponent={this.renderHeader}
          data={items.map(item => ({ ...item, key: item.id }))}
          renderItem={this.renderRubricItem}
          initialNumToRender={2}
          extraData={this.state}
        />
        {this.renderCommentInput()}
      </View>
    )
  }
}

const styles = StyleSheet.create({
  rubricHeader: {
    paddingHorizontal: 16,
    marginTop: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  saveStyles: {
    fontSize: 18,
    fontWeight: '600',
  },
  pointsText: {
    color: colors.grey4,
    fontSize: 14,
  },
})

export function mapStateToProps (state: AppState, ownProps: RubricOwnProps): RubricDataProps {
  let assignment = state.entities.assignments[ownProps.assignmentID].data
  let submission = state.entities.submissions[ownProps.submissionID]
  let assessments = null
  let rubricGradePending = false

  if (submission) {
    assessments = {
      ...submission.submission.rubric_assessment,
      ...ownProps.unsavedChanges,
    }
    rubricGradePending = submission.rubricGradePending
  }

  return {
    rubricItems: assignment.rubric,
    rubricSettings: assignment.rubric_settings,
    rubricAssessment: assessments,
    rubricGradePending,
    useRubricForGrading: assignment.use_rubric_for_grading,
  }
}

const Connected = connect(mapStateToProps, SpeedGraderActions)(GradeTab)
export default (Connected: any)

type RubricOwnProps = {
  courseID: string,
  assignmentID: string,
  submissionID: string,
  userID: string,
  navigator: Navigator,
  drawerState: DrawerState,
  showToolTip?: (sourcePoint: { x: number, y: number }, tip: string) => void,
  dismissToolTip?: () => void,
  isModeratedGrading: boolean,
  updateUnsavedChanges: Function,
  unsavedChanges: { [string]: RubricAssessment },
}

type RubricDataProps = {
  rubricItems: ?Array<Rubric>,
  rubricSettings: ?RubricSettings,
  rubricAssessment: ?{ [string]: RubricAssessment },
  rubricGradePending: boolean,
  useRubricForGrading: boolean,
}

type RubricActionProps = {
  gradeSubmissionWithRubric: Function,
}

type GradeTabProps = RubricOwnProps & RubricDataProps & RubricActionProps
type GradeTabState = {
  ratings: { [string]: RubricAssessment },
  criterionCommentInput: ?string,
}
